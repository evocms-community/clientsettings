<?php

if (IN_MANAGER_MODE != 'true' || empty($modx) || !($modx instanceof DocumentParser)) {
    die('Please use the MODX Content Manager instead of accessing this file directly.');
}

$managerPath = $modx->getManagerPath();

if (!$modx->hasPermission('exec_module')) {
    $modx->sendRedirect('index.php?a=106');
}

if (!is_array($modx->event->params)) {
    $modx->event->params = [];
}

if (!function_exists('renderFormElement')) {
    include_once(MODX_MANAGER_PATH . 'includes/tmplvars.commands.inc.php');
    include_once(MODX_MANAGER_PATH . 'includes/tmplvars.inc.php');
}

$tabs = [];

foreach (glob(__DIR__ . '/config/*.php') as $file) {
    $tabs[pathinfo($file, PATHINFO_FILENAME)] = include $file;
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $fields = [];

    foreach ($tabs as $tab) {
        foreach (array_keys($tab['settings']) as $field) {
            $postfield = 'tv' . $field;

            if (isset($_POST[$postfield])) {
                $fields[] = [$params['prefix'] . $field, $_POST[$postfield]];
            }
        }
    }

    if (!empty($fields)) {
        $modx->db->query("REPLACE INTO " . $modx->getFullTableName('system_settings') . " (setting_name, setting_value) VALUES " . implode(', ', array_map(function($row) use ($modx) {
            return "('" . $modx->db->escape($row[0]) . "', '" . $modx->db->escape($row[1]) . "')";
        }, $fields)));
        $modx->clearCache('full');
        $modx->sendRedirect('index.php?a=7&r=10');
    }
}

$userlang    = $modx->getConfig('manager_language');
$_customlang = include MODX_BASE_PATH . 'assets/modules/clientsettings/lang.php';
$title       = isset($_customlang[$userlang]) ? $_customlang[$userlang] : reset($_customlang);
$_lang       = [];

include MODX_MANAGER_PATH . 'includes/lang/' . $userlang . '.inc.php';

include_once MODX_MANAGER_PATH . 'includes/header.inc.php';

?>

<h1>
    <i class="fa fa-cog"></i><?= $title ?> 
</h1>
    
<?php if (empty($tabs)): ?>
    <div class="tab-page">
        <div class="container-body">
            Configuration not found. Rename <code>assets/modules/clientsettings/config/*.sample</code> files or create new ones.
        </div>
    </div>
<?php else: ?>
    <form name="settings" method="post" id="mutate">
        <div id="actions">
            <div class="btn-group">
                <button id="Button1" class="btn btn-success" type="submit" onclick="documentDirty = false;">
                    <i class="fa fa-floppy-o"></i><span><?= $_lang['save'] ?></span>
                </button>

                <a id="Button5" class="btn btn-secondary" href="<?= $managerPath ?>index.php?a=2">
                    <i class="fa fa-times-circle"></i><span><?= $_lang['cancel'] ?></span>
                </a>
            </div>
        </div>

        <div class="sectionBody" id="settingsPane">
            <div class="dynamic-tab-pane-control tab-pane" id="documentPane">
                <script type="text/javascript">
                    var tpSettings = new WebFXTabPane(document.getElementById('documentPane'), <?= ($modx->config['remember_last_tab'] == 1 ? 'true' : 'false') ?> );
                </script> 

                <?php foreach ($tabs as $name => $tab): ?>
                    <div class="tab-page" id="tab_<?= $name ?>">
                        <h2 class="tab"><?= $tab['caption'] ?></h2>
            
                        <script type="text/javascript">
                            tpSettings.addTabPage(document.getElementById('tab_<?= $name ?>'));
                        </script>
            
                        <table border="0" cellspacing="0" cellpadding="3">
                            <?php foreach ($tab['settings'] as $field => $options): ?>
                                <tr>
                                    <td class="warning" nowrap="">
                                        <?= $options['caption'] ?><br>
                                        <small>[(<?= $params['prefix'] . $field ?>)]</small>
                                    </td>

                                    <td data-type="<?= $options['type'] ?>">
                                        <?= renderFormElement(
                                            $options['type'],
                                            $field,
                                            '',
                                            isset($options['elements']) ? $options['elements'] : '',
                                            trim($modx->getConfig($params['prefix'] . $field)),
                                            isset($options['style']) ? 'style="' . $options['style'] . '"' : '',
                                            [
                                                'type' => $options['type'],
                                                'name' => $field,
                                                'caption' => $options['caption'],
                                                'id' => $field,
                                                'default_text' => '',
                                                'value' => $modx->getConfig($params['prefix'] . $field),
                                                'elements' => isset($options['elements']) ? $options['elements'] : '',
                                            ]
                                        ); ?>

                                        <?php if (isset($options['note'])): ?>
                                            <div class="comment">
                                                <?= $options['note'] ?>
                                            </div>
                                        <?php endif; ?>
                                    </td>
                                </tr>

                                <tr>
                                    <td colspan="2"><div class="split"></div></td>
                                </tr>
                            <?php endforeach; ?>
                        </table>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
    </form>
<?php endif; ?>

<?php

$mmPath = MODX_BASE_PATH . 'assets/plugins/managermanager/mm.inc.php';

if (is_readable($mmPath)) {
    include_once $mmPath;

    if (isset($jsUrls['ddTools'])) {
        ?>
            <script>
                $j = jQuery;
            </script>
            <script src="<?= $jsUrls['mm']['url'] ?>"></script>
            <script src="<?= $jsUrls['ddTools']['url'] ?>"></script>
            <script src="<?= $modx->config['site_url'] . 'assets/plugins/managermanager/widgets/showimagetvs/jquery.ddMM.mm_widget_showimagetvs.js' ?>"></script>
            <script>
                <?= initJQddManagerManager(); ?>

                $j('[data-type="image"] > [type="text"]').mm_widget_showimagetvs({
                    thumbnailerUrl: '',
                    width: 300,
                    height: 100,
                });
            </script>
        <?php
    }
}

include_once MODX_MANAGER_PATH . 'includes/footer.inc.php';
