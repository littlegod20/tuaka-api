<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invites', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('tenant_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('invited_by')->constrained('users')->cascadeOnDelete();
            $table->string('email');
            $table->string('role')->default('member'); // admin | member
            $table->string('token', 64)->unique();
            $table->timestamp('expires_at');
            $table->timestamp('accepted_at')->nullable();
            $table->timestamps();

            $table->unique(['tenant_id', 'email']); // one pending invite per email per tenant
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invites');
    }
};