/**
 * ClientSettings
 *
 * Creates menu item for user module ClientSettings
 *
 * @category    plugin
 * @version     1.2.10
 * @author      mnoskov
 * @internal    @events OnManagerMenuPrerender
 * @internal    @modx_category Manager and Admin
 */
//<?php

switch ($modx->event->name) {
    case 'OnManagerMenuPrerender': {
        $dir = MODX_BASE_PATH . 'assets/modules/clientsettings/';
        $_customlang = include $dir . 'lang.php';

        $userlang = $modx->getConfig('manager_language');
        $langitem = isset($_customlang[$userlang]) ? $_customlang[$userlang] : reset($_customlang);

        $moduleid = $modx->db->getValue($modx->db->select('id', $modx->getFullTablename('site_modules'), "name = 'ClientSettings'"));

        $items = [];

        foreach (glob($dir . 'config/*.php') as $file) {
            $config = include $file;

            if (isset($config['menu']['alias'])) {
                $items[$config['menu']['alias']] = $config['menu'];
            }
        }

        $menuparams = ['client_settings', 'main', '<i class="fa fa-cog"></i>' . $langitem, 'index.php?a=112&id=' . $moduleid, $langitem, '', '', 'main', 0, 100, ''];

        if (!empty($items)) {
            $menuparams[3] = 'javscript:;';
            $menuparams[5] = 'return false;';
            $sort = 0;

            $params['menu']['client_settings_main'] = ['client_settings_main', 'client_settings', '<i class="fa fa-cog"></i>' . $langitem, 'index.php?a=112&id=' . $moduleid, $langitem, '', '', 'main', 0, $sort, ''];

            foreach ($items as $alias => $item) {
                $params['menu']['client_settings_' . $alias] = ['client_settings_' . $alias, 'client_settings', '<i class="fa ' . (isset($item['icon']) ? $item['icon'] : 'fa-cog') . '"></i>' . $item['caption'], 'index.php?a=112&id=' . $moduleid . '&menu=' . $alias, $item['caption'], '', '', 'main', 0, $sort += 10, ''];
            }
        }

        $params['menu']['client_settings'] = $menuparams;

        $modx->event->output(serialize($params['menu']));
        return;
    }
}
