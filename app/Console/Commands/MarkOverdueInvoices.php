<?php

namespace App\Console\Commands;

use App\Models\Invoice;
use Illuminate\Console\Command;

class MarkOverdueInvoices extends Command
{
    protected $signature   = 'invoices:mark-overdue';
    protected $description = 'Mark sent/viewed invoices as overdue when due date has passed';

    public function handle(): void
    {
        $count = Invoice::withoutGlobalScopes()
            ->whereIn('status', ['sent', 'viewed'])
            ->where('type', 'invoice')
            ->whereNotNull('due_date')
            ->whereDate('due_date', '<', now()->toDateString())
            ->update(['status' => 'overdue']);

        $this->info("Marked {$count} invoice(s) as overdue.");
    }
}