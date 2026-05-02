<?php

namespace App\Traits;

use App\Scopes\TenantScope;
use Illuminate\Database\Eloquent\Model;

trait HasTenant
{
    /**
     * Boot the trait — registers the global scope automatically
     * on any model that uses this trait.
     */
    public static function bootHasTenant(): void
    {
        // Apply tenant scope on every query
        static::addGlobalScope(new TenantScope());

        // Automatically stamp tenant_id on every new record
        static::creating(function (Model $model) {
            if (! $model->tenant_id) {
                $tenant = app('current_tenant');
                if ($tenant) {
                    $model->tenant_id = $tenant->id;
                }
            }
        });
    }
}
