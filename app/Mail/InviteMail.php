<?php

namespace App\Mail;

use App\Models\Invite;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class InviteMail extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly Invite $invite,
        public readonly string $acceptUrl,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: "You've been invited to join {$this->invite->tenant->name} on TuaKa",
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.invite',
            with: [
                'invite'    => $this->invite,
                'acceptUrl' => $this->acceptUrl,
                'tenant'    => $this->invite->tenant,
                'invitedBy' => $this->invite->invitedBy,
            ],
        );
    }
}