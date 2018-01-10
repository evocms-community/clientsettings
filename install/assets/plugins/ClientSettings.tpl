/**
 * ClientSettings
 * 
 * Creates menu item for user module ClientSettings
 *
 * @category    plugin
 * @version     1.0.0
 * @author      mnoskov
 * @internal    @events OnManagerMenuPrerender
 * @internal    @modx_category Manager and Admin
 */
$e = &$modx->event;

switch ($e->name) {
    case 'OnManagerMenuPrerender': {
        $params['menu']['client_settings'] = [
            'client_settings',
            'main',
            '<i class="fa fa-cog"></i>Настройки сайта',
            'index.php?a=112&id=5',
            'Настройки сайта',
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
