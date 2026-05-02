<?php

namespace App\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class TenantScope implements Scope
{
    /**
     * Apply the scope to a given Eloquent query builder.
     * This runs automatically on every query for any model
     * that uses the HasTenant trait.
     */
    public function apply(Builder $builder, Model $model): void
    {
        $tenant = app('current_tenant');

        if ($tenant) {
            $builder->where(
                $model->getTable() . '.tenant_id',
                $tenant->id
            );
        }
    }
}
