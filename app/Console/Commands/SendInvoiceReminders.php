<?php

namespace App\Console\Commands;

use App\Mail\InvoiceReminderMail;
use App\Models\Invoice;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class SendInvoiceReminders extends Command
{
    protected $signature   = 'invoices:send-reminders';
    protected $description = 'Send payment reminders for invoices due in 3 days and 1 day';

    // Send reminders when due_date is this many days away
    private array $reminderDays = [3, 1];

    public function handle(): void
    {
        $sent = 0;

        foreach ($this->reminderDays as $days) {
            $targetDate = now()->addDays($days)->toDateString();

            $invoices = Invoice::withoutGlobalScopes()
                ->with(['client', 'tenant'])
                ->whereIn('status', ['sent', 'viewed'])
                ->where('type', 'invoice')
                ->whereNotNull('due_date')
                ->whereDate('due_date', $targetDate)
                ->whereNotNull('view_token')
                ->get();

            foreach ($invoices as $invoice) {
                if (! $invoice->client?->email) continue;
                if (! $invoice->tenant) continue;

                $url = config('app.frontend_url')
                    . '/inv/' . $invoice->view_token;

                Mail::to($invoice->client->email)
                    ->queue(new InvoiceReminderMail($invoice, $url, $days));

                $invoice->activities()->create([
                    'type' => 'reminder',
                    'meta' => [
                        'days_until_due' => $days,
                        'sent_to'        => $invoice->client->email,
                        'sent_at'        => now()->toIso8601String(),
                    ],
                ]);

                $sent++;
                $this->line("Reminder sent for {$invoice->number} → {$invoice->client->email} ({$days}d)");
            }
        }

        $this->info("Sent {$sent} reminder(s).");
    }
}