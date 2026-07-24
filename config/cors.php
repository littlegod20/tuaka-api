
<?php

return [
    'paths' => ['api/*', 'webhooks/*', 'inv/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'https://admin.tuaka.org',  // admin portal
	'https://www.tuaka.org',
        'https://tuaka.org',
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
