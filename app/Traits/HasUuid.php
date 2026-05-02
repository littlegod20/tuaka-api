<?php

namespace App\Traits;

use Illuminate\Support\Str;

trait HasUuid
{
    /**
     * Boot the trait — generates a UUID before
     * creating any new model instance.
     */
    public static function bootHasUuid(): void
    {
        static::creating(function ($model) {
            if (! $model->getKey()) {
                $model->{$model->getKeyName()} = (string) Str::uuid();
            }
        });
    }

    /**
     * Tell Eloquent the primary key is not auto-incrementing.
     */
    public function getIncrementing(): bool
    {
        return false;
    }

    /**
     * Tell Eloquent the primary key type is a string (UUID).
     */
    public function getKeyType(): string
    {
        return 'string';
    }
}
