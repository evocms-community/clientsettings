/**
 * ClientSettings Installer
 *
 * Events, relations install
 *
 * @category    plugin
 * @author      mnoskov
 * @internal    @events OnWebPageInit,OnManagerPageInit
 * @internal    @modx_category Manager and Admin
 */
//<?php

$packageName = 'ClientSettings';

$events = [
    'OnBeforeClientSettingsSave',
    'OnClientSettingsSave',
];

switch ($modx->event->name) {
    case 'OnWebPageInit':
    case 'OnManagerPageInit': {
        $modx->clearCache('full');

        $tableEvents       = $modx->getFullTableName('system_eventnames');
        $tablePlugins      = $modx->getFullTableName('site_plugins');
        $tablePluginEvents = $modx->getFullTableName('site_plugin_events');
        $tableModules      = $modx->getFullTableName('site_modules');
        $tableDependencies = $modx->getFullTableName('site_module_depobj');

        $module = $modx->db->getRow($modx->db->select('id, guid', $tableModules, "`name` = '$packageName'"));

        if ($module) {
            // включаем общие параметры в настройках модуля
            $modx->db->update(['enable_sharedparams' => 1], $tableModules, '`id` = "' . $module['id'] . '"');

            $pluginId = $modx->db->getValue($modx->db->select('id', $tablePlugins, "`name` = '$packageName'"));

            if ($pluginId) {
                $query = $modx->db->select('id', $tableDependencies, "`resource` = '$pluginId' AND `module` = '" . $module['id'] . "' AND `type` = 30");

                if (!$modx->db->getRecordCount($query)) {
                    $modx->db->update(['moduleguid' => $module['guid']], $tablePlugins, "`id` = '$pluginId'");
                    $modx->db->insert([
                        'module'   => $module['id'],
                        'resource' => $pluginId,
                        'type'     => 30,
                    ], $tableDependencies);
                }
            }

            $query  = $modx->db->select('*', $tableEvents, "`groupname` = '$packageName'");
            $exists = [];

            while ($row = $modx->db->getRow($query)) {
                $exists[$row['name']] = $row['id'];
            }

            foreach ($events as $event) {
                if (!isset($exists[$event])) {
                    $modx->db->insert([
                        'name'      => $event,
                        'service'   => 6,
                        'groupname' => $packageName,
                    ], $tableEvents);
                }
            }
        }

        // удаляем установщик
        $query = $modx->db->select('id', $tablePlugins, "`name` = '" . $modx->event->activePlugin . "'");

        if ($id = $modx->db->getValue($query)) {
           $modx->db->delete($tablePlugins, "`id` = '$id'");
           $modx->db->delete($tablePluginEvents, "`pluginid` = '$id'");
        }
    }
}
