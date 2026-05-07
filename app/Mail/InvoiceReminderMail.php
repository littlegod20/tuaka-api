<?php

namespace App\Mail;

use App\Models\Invoice;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class InvoiceReminderMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly Invoice $invoice,
        public readonly string  $invoiceUrl,
        public readonly int     $daysUntilDue,
    ) {}

    public function envelope(): Envelope
    {
        $subject = $this->daysUntilDue > 0
            ? "Reminder: Invoice {$this->invoice->number} is due in {$this->daysUntilDue} day(s)"
            : "Overdue: Invoice {$this->invoice->number} was due today";

        return new Envelope(subject: $subject);
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.invoice-reminder',
            with: [
                'invoice'       => $this->invoice,
                'invoiceUrl'    => $this->invoiceUrl,
                'tenant'        => $this->invoice->tenant,
                'client'        => $this->invoice->client,
                'daysUntilDue'  => $this->daysUntilDue,
            ],
        );
    }
}