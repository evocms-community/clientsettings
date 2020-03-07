/**
 * ClientSettings
 *
 * Creates menu item for user module ClientSettings
 *
 * @category    plugin
 * @version     2.0.2
 * @author      mnoskov
 * @internal    @events OnManagerMenuPrerender
 * @internal    @modx_category Manager and Admin
 */
//<?php

if ($modx->event->name == 'OnManagerMenuPrerender') {
    require_once MODX_BASE_PATH . 'assets/modules/clientsettings/core/src/ClientSettings.php';

    $cs   = new ClientSettings($params);
    $mid  = $cs->getModuleId();
    $lang = $cs->loadLang();
    $tabs = $cs->loadStructure();

    $menuparams = ['client_settings', 'main', '<i class="fa fa-cog"></i>' . $lang['cs.module_title'], 'index.php?a=112&id=' . $mid . '&type=default', $lang['cs.module_title'], '', '', 'main', 0, 100, ''];

    if (count($tabs) > 1) {
        $menuparams[3] = 'javscript:;';
        $menuparams[5] = 'return false;';
        $sort = 0;

        $params['menu']['client_settings_main'] = ['client_settings_main', 'client_settings', '<i class="fa fa-cog"></i>' . $lang['cs.module_title'], 'index.php?a=112&id=' . $mid . '&type=default', $lang['cs.module_title'], '', '', 'main', 0, $sort, ''];

        foreach ($tabs as $alias => $item) {
            if ($alias != 'default') {
                $params['menu']['client_settings_' . $alias] = ['client_settings_' . $alias, 'client_settings', '<i class="fa ' . (isset($item['menu']['icon']) ? $item['menu']['icon'] : 'fa-cog') . '"></i>' . $item['menu']['caption'], 'index.php?a=112&id=' . $mid . '&type=' . $alias, $item['menu']['caption'], '', '', 'main', 0, $sort += 10, ''];
            }
        }
    }

    $params['menu']['client_settings'] = $menuparams;
    $modx->event->output(serialize($params['menu']));
    return;
}
