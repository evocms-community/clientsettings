/**
 * ClientSettings
 * 
 * Creates menu item for user module ClientSettings
 *
 * @category    plugin
 * @version     1.0.1
 * @author      mnoskov
 * @internal    @events OnManagerMenuPrerender
 * @internal    @modx_category Manager and Admin
 */
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
}
