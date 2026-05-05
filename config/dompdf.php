<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Settings
    |--------------------------------------------------------------------------
    |
    | Set some default values. It is possible to add all defines that can be set
    | in dompdf_config.inc.php. You can also override the entire config file.
    |
    */
    'show_warnings' => false,   // Throw an Exception on warnings from dompdf

    'public_path' => null,  // Override the public path if needed

    /*
     * Dejavu Sans font is missing glyphs for converted entities, turn it off if you need to show € and £.
     */
    'convert_entities' => true,

    'options' => [
        'font_dir'                => storage_path('fonts/'),
        'font_cache'              => storage_path('fonts/'),
        'default_font'            => 'dejavu sans',
        'dpi'                     => 150,
        'enable_php'              => false,
        'enable_remote'           => false,
        'chroot'                  => realpath(base_path()),
        'allowed_protocols'       => [],
        'log_output_file'         => null,
        'enable_html5_parser'     => true,
    ],

];
