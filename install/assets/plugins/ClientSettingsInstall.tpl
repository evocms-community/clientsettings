/**
 * ClientSettings Installer
 *
 * Events install
 *
 * @category    plugin
 * @version     1.2.7
 * @author      mnoskov
 * @internal    @events OnWebPageInit,OnManagerPageInit
 * @internal    @modx_category Manager and Admin
 */
//<?php

switch ($modx->event->name) {
    case 'OnWebPageInit':
    case 'OnManagerPageInit': {
        $modx->clearCache('full');

        $events = [
            'OnBeforeClientSettingsSave',
            'OnClientSettingsSave',
        ];

        $tableEvents  = $modx->getFullTableName('system_eventnames');
        $tablePlugins = $modx->getFullTableName('site_plugins');

        $query  = $modx->db->select('*', $tableEvents, "`groupname` = 'ClientSettings'");
        $exists = [];

        while ($row = $modx->db->getRow($query)) {
            $exists[$row['name']] = $row['id'];
        }

        foreach ($events as $event) {
            if (!isset($exists[$event])) {
                $modx->db->insert([
                    'name'      => $event,
                    'service'   => 6,
                    'groupname' => 'ClientSettings',
                ], $tableEvents);
            }
        }

        $query = $modx->db->select('id', $tablePlugins, "`name` = '" . $modx->event->activePlugin . "'");

        if ($id = $modx->db->getValue($query)) {
           $modx->db->delete($tablePlugins, "`id` = '$id'");
           $modx->db->delete($tableEvents, "`pluginid` = '$id'");
        }
    }
}
