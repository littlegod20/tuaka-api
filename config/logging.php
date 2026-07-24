<?php

use Monolog\Handler\NullHandler;
use Monolog\Handler\StreamHandler;
use Monolog\Handler\SyslogUdpHandler;
use Monolog\Processor\PsrLogMessageProcessor;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Log Channel
    |--------------------------------------------------------------------------
    |
    | This option defines the default log channel that is utilized to write
    | messages to your logs. The value provided here should match one of
    | the channels present in the list of "channels" configured below.
    |
    */

    'default' => env('LOG_CHANNEL', 'stack'),

    /*
    |--------------------------------------------------------------------------
    | Deprecations Log Channel
    |--------------------------------------------------------------------------
    |
    | This option controls the log channel that should be used to log warnings
    | regarding deprecated PHP and library features. This allows you to get
    | your application ready for upcoming major versions of dependencies.
    |
    */

    'deprecations' => [
        'channel' => env('LOG_DEPRECATIONS_CHANNEL', 'null'),
        'trace' => env('LOG_DEPRECATIONS_TRACE', false),
    ],

    /*
    |--------------------------------------------------------------------------
    | Log Channels
    |--------------------------------------------------------------------------
    |
    | Here you may configure the log channels for your application. Laravel
    | utilizes the Monolog PHP logging library, which includes a variety
    | of powerful log handlers and formatters that you're free to use.
    |
    | Available drivers: "single", "daily", "slack", "syslog",
    |                    "errorlog", "monolog", "custom", "stack"
    |
    */

    'channels' => [

        'stack' => [
            'driver' => 'stack',
            'channels'          => ['daily', 'stderr', 'sentry_logs'],
            'ignore_exceptions' => false,
        ],

        'sentry_logs' => [
            'driver' => 'sentry_logs',
            'level'  => env('LOG_LEVEL', 'info'),
        ],

        // ─── Single file (simple debugging) ──────────────────────────
        'single' => [
            'driver' => 'single',
            'path' => storage_path('logs/laravel.log'),
            'level' => env('LOG_LEVEL', 'debug'),
            'replace_placeholders' => true,
        ],


         // ─── Daily rotating log ───────────────────────────────────────
        // Keeps 30 days of logs, auto-deletes older files
        'daily' => [
            'driver' => 'daily',
            'path' => storage_path('logs/laravel.log'),
            'level' => env('LOG_LEVEL', 'debug'),
            'days'   => 30,
            'replace_placeholders' => true,
        ],


        // ─── Payment events ───────────────────────────────────────────
        // Separate file for all payment-related logs
        // Makes it easy to audit financial events in isolation
        'payments' => [
            'driver' => 'daily',
            'path'   => storage_path('logs/payments.log'),
            'level'  => 'debug',
            'days'   => 90, // keep 90 days for financial records
            'replace_placeholders' => true,
        ],



        // ─── Tenant activity ──────────────────────────────────────────
        // Logs significant tenant actions for support and debugging
        'tenants' => [
            'driver' => 'daily',
            'path'   => storage_path('logs/tenants.log'),
            'level'  => 'info',
            'days'   => 60,
            'replace_placeholders' => true,
        ],


        // ─── Queue / jobs ─────────────────────────────────────────────
        'jobs' => [
            'driver' => 'daily',
            'path'   => storage_path('logs/jobs.log'),
            'level'  => 'debug',
            'days'   => 30,
            'replace_placeholders' => true,
        ],


        // ─── Auth / security audit ────────────────────────────────────
        'auth' => [
            'driver' => 'daily',
            'path'   => storage_path('logs/auth.log'),
            'level'  => 'info',
            'days'   => 90,
            'replace_placeholders' => true,
        ],


        // ─── Stderr (production) ──────────────────────────────────────
        // Writes to stderr so server monitoring tools can capture it
        'stderr' => [
            'driver' => 'monolog',
            'level' => env('LOG_LEVEL', 'debug'),
            'handler' => StreamHandler::class,
            'handler_with' => [
                'stream' => 'php://stderr',
            ],
            'formatter' => env('LOG_STDERR_FORMATTER'),
            'processors' => [PsrLogMessageProcessor::class],
        ],

        'syslog' => [
            'driver' => 'syslog',
            'level' => env('LOG_LEVEL', 'debug'),
            'facility' => env('LOG_SYSLOG_FACILITY', LOG_USER),
            'replace_placeholders' => true,
        ],

        'errorlog' => [
            'driver' => 'errorlog',
            'level' => env('LOG_LEVEL', 'debug'),
            'replace_placeholders' => true,
        ],

        'null' => [
            'driver' => 'monolog',
            'handler' => NullHandler::class,
        ],

        'emergency' => [
            'path' => storage_path('logs/laravel.log'),
        ],

    ],

];
