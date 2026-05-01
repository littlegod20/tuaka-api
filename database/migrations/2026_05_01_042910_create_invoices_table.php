<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('invoices', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('tenant_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('client_id')->constrained()->cascadeOnDelete();
            $table->string('number');         // INV-0001
            $table->string('type')->default('invoice');  // invoice | quote
            $table->string('status')->default('draft');
            $table->string('view_token')->unique()->nullable();
            $table->integer('subtotal')->default(0);
            $table->integer('tax_rate')->default(0);    // percentage e.g. 15
            $table->integer('tax_amount')->default(0);
            $table->integer('total')->default(0);
            $table->text('notes')->nullable();
            $table->date('due_date')->nullable();
            $table->timestamp('sent_at')->nullable();
            $table->timestamp('viewed_at')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
    
            // tenant-scoped unique invoice number
            $table->unique(['tenant_id', 'number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('invoices');
    }
};
