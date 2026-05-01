<?php

return [
    'paths' => ['api/*', 'webhooks/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:3000',  // admin portal
        'http://localhost:3001',  // business portal
        env('FRONTEND_URL'),
    ],

    'allowed_origins_patterns' => [
        // allows any subdomain of tuaka.app in production
        '#^https://[a-z0-9\-]+\.tuaka\.app$#',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,
];