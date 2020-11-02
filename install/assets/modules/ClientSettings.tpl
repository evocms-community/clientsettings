/**
 * ClientSettings
 *
 * Customizable set of fields for user settings
 *
 * @category    module
 * @version     2.1.1
 * @author      mnoskov
 * @internal	@guid clsee234523g354f542t5t
 * @internal    @properties &prefix=Prefix for settings;text;client_ &config_path=Path to configuration files;text;
 * @internal    @modx_category Manager and Admin
 */
//<?php

require_once MODX_BASE_PATH . 'assets/modules/clientsettings/core/src/ClientSettings.php';

if (!$modx->hasPermission('exec_module')) {
    $modx->sendRedirect('index.php?a=106');
}

if (!is_array($modx->event->params)) {
    $modx->event->params = [];
}

if (!function_exists('renderFormElement')) {
    include_once MODX_MANAGER_PATH . 'includes/tmplvars.commands.inc.php';
    include_once MODX_MANAGER_PATH . 'includes/tmplvars.inc.php';
}

if (isset($_REQUEST['stay'])) {
    $_SESSION['stay'] = $_REQUEST['stay'];
} else if (isset($_SESSION['stay'])) {
    $_REQUEST['stay'] = $_SESSION['stay'];
}

(new ClientSettings($params))->processRequest();
