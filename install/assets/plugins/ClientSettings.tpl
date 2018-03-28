/**
 * ClientSettings
 * 
 * Events install, creates menu item for user module ClientSettings
 *
 * @category    plugin
 * @version     1.2.4
 * @author      mnoskov
 * @internal    @events OnWebPageInit,OnManagerPageInit,OnManagerMenuPrerender
 * @internal    @modx_category Manager and Admin
 */
//<?php
$e = &$modx->event;

switch ($e->name) {
    case 'OnManagerMenuPrerender': {
        $_customlang = include MODX_BASE_PATH . 'assets/modules/clientsettings/lang.php';
        
        $userlang = $modx->getConfig('manager_language');
        $langitem = isset($_customlang[$userlang]) ? $_customlang[$userlang] : reset($_customlang);
        
        $moduleid = $modx->db->getValue($modx->db->select('id', $modx->getFullTablename('site_modules'), "name = 'ClientSettings'"));
        
        $params['menu']['client_settings'] = [
            'client_settings',
            'main',
            '<i class="fa fa-cog"></i>' . $langitem,
            'index.php?a=112&id=' . $moduleid,
            $langitem,
            '',
            '',
            'main',
            0,
            100,
            '',
        ];
        
        $e->output(serialize($params['menu']));
        return;
    }

    case 'OnWebPageInit':
    case 'OnManagerPageInit': {
        $modx->db->query("DELETE FROM " . $modx->getFullTableName('site_plugin_events') . "
            WHERE pluginid IN (
               SELECT id
               FROM " . $modx->getFullTableName('site_plugins') . "
               WHERE name = '" . $e->activePlugin . "'
               AND disabled = 0
            )
            AND evtid IN (
               SELECT id
               FROM " . $modx->getFullTableName('system_eventnames') . "
               WHERE name IN ('OnWebPageInit', 'OnManagerPageInit')
            )");

        $modx->clearCache('full');

        $table  = $modx->getFullTableName('system_eventnames');
        $events = ['OnBeforeClientSettingsSave', 'OnClientSettingsSave'];
        $query  = $modx->db->select('*', $table, "`name` IN ('" . implode("', '", $events) . "')");

        $events = array_flip($events);
        while ($row = $modx->db->getRow($query)) {
            if (isset($events[$row['name']])) {
                unset($events[$row['name']]);
            }
        }

        foreach (array_flip($events) as $event) {
            $modx->db->insert([
                'name'      => $event,
                'service'   => 6,
                'groupname' => 'ClientSettings',
            ], $table);
        }

        return;
    }
}
