<?php

namespace App\Mail;

use App\Models\Invoice; 
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Attachment;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class InvoiceMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     */
    public function __construct(
        public readonly Invoice $invoice,
        public readonly string $invoiceUrl,
    ) {}

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        $subject = $this->invoice->isQuote()
            ? "Quote {$this->invoice->number} from {$this->invoice->tenant->name}"
            : "Invoice {$this->invoice->number} from {$this->invoice->tenant->name}";

        return new Envelope(subject: $subject);
    }
    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.invoice',
            with: [
                'invoice'    => $this->invoice,
                'invoiceUrl' => $this->invoiceUrl,
                'tenant'     => $this->invoice->tenant,
                'client'     => $this->invoice->client,
            ],
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
