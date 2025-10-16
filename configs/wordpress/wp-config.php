<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */

$db_name     = getenv('WORDPRESS_DB_NAME') ? getenv('WORDPRESS_DB_NAME') : 'wpdatabase';
$db_user     = getenv('WORDPRESS_DB_USER') ? getenv('WORDPRESS_DB_USER') : 'wpuser';
$db_password = getenv('WORDPRESS_DB_PASSWORD') ? getenv('WORDPRESS_DB_PASSWORD') : 'wppassword';
$db_host     = getenv('WORDPRESS_DB_HOST') ? getenv('WORDPRESS_DB_HOST') : 'localhost';
$enviroment  = getenv('MODE_URL') ? getenv('MODE_URL') : "https://quijotefilms.com";

// Configuración base de datos
define('DB_NAME',$db_name);
define('DB_USER',$db_user);
define('DB_PASSWORD',$db_password);
define('DB_HOST',$db_host);
define('DB_CHARSET',  'utf8');
define('DB_COLLATE',  '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'T=mt>KvKvqoR%H%^?j,])}B@2XW[mg5nMV.<5q*pV-cD7uynbRhUUY@`NKv/qxU_');
define('SECURE_AUTH_KEY',  'V(SDOFEgd!Sfh=&#iyMT7x3FB._E1:2WY3+AiOx::fH] .f`rWp<ym9(A@Y&h,;I');
define('LOGGED_IN_KEY',    'v;cFCa*H3dJzyMx Z&RHI#-lS}AbrD$~:!FI&s~8?`M?%@8<}-G<8R~*g}*xu.G-');
define('NONCE_KEY',        '&2TabK1Jfg<g#T.jC~l,x28l`j~XmAdk(dp4Mo5mtDU-BR{`z GO@()fk|/^s.n3');
define('AUTH_SALT',        'w_?B}y<a<O~@q14S`{^o77%,N &B66K+L0kwNn;~}OmD*,8vlLgAwP1Kbs=w@n`k');
define('SECURE_AUTH_SALT', 'xwB`uhL]Z glhds{Krn`g^1n3IkN^}hys(+S6O[QPap%a@lM%>Ua1^_&MwMs&a1L');
define('LOGGED_IN_SALT',   '*O!,shKK@G46!73<]T8)Hi,-OUbl)$(%bOf9@zo*f N&a0;1Ic!!W5uEA6 `=oVF');
define('NONCE_SALT',       'i?6JR&J;{zGkNr1jK5NhaPAWlGbZ!_3j/WgjvrZ-Ind{%pv8jorxd1bfvy `~br&');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', true);
define('WP_DEBUG_DISPLAY', true);
@ini_set('display_errors', 0);


define('WP_HOME',$enviroment);
define('WP_SITEURL',$enviroment);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
