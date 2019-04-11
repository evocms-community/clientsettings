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

if (isset($_REQUEST['stay'])) {
    $_SESSION['stay'] = $_REQUEST['stay'];
} else if (isset($_SESSION['stay'])) {
    $_REQUEST['stay'] = $_SESSION['stay'];
}

$stay = isset($_REQUEST['stay']) ? $_REQUEST['stay'] : '';

$tabs = [];

foreach (glob(__DIR__ . '/config/*.php') as $file) {
    $tabs[pathinfo($file, PATHINFO_FILENAME)] = include $file;
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $fields = [];

    foreach ($tabs as $tab) {
        foreach (array_keys($tab['settings']) as $field) {
            $postfield = 'tv' . $field;

            $type = $tab['settings'][$field]['type'];

            if (isset($_POST[$postfield])) {
                $value = $_POST[$postfield];
            } else if (isset($tab['settings'][$field]['default_value'])) {
                $value = $tab['settings'][$field]['default_value'];
            } else {
                $value = '';
            }

            switch ($type) {
                case 'url':
                    if ($_POST[$postfield . '_prefix'] != '--') {
                        $value = str_replace(array (
                            "feed://",
                            "ftp://",
                            "http://",
                            "https://",
                            "mailto:"
                        ), "", $value);
                        $value = $_POST[$postfield . '_prefix'] . $value;
                    }
                    break;

                case 'custom_tv:multitv': {
                    $json = @json_decode($value);

                    if (isset($json->fieldValue)) {
                        $value = json_encode($json->fieldValue, JSON_UNESCAPED_UNICODE);
                    }
                    break;
                }

                default:
                    if (is_array($value)) {
                        $value = implode("||", $value);
                    }
                    break;
            }

            $fields[$field] = [$params['prefix'] . $field, $value];
        }
    }

    $modx->invokeEvent('OnBeforeClientSettingsSave', [
        'fields' => &$fields,
    ]);

    if (!empty($fields)) {
        $modx->db->query("REPLACE INTO " . $modx->getFullTableName('system_settings') . " (setting_name, setting_value) VALUES " . implode(', ', array_map(function($row) use ($modx) {
            return "('" . $modx->db->escape($row[0]) . "', '" . $modx->db->escape($row[1]) . "')";
        }, $fields)));
    }

    $modx->invokeEvent('OnDocFormSave', [
        'mode' => 'upd',
        'id'   => 0,
    ]);

    $modx->invokeEvent('OnClientSettingsSave', [
        'fields' => $fields,
    ]);

    $modx->clearCache('full');

    if ($stay == 2) {
        $modx->sendRedirect('index.php?a=112&id=' . $_GET['id']);
    } else {
        $modx->sendRedirect('index.php?a=7&r=10');
    }
}

global $content, $_style, $lastInstallTime;
$content['richtext'] = 1;

if (!isset($_COOKIE['MODX_themeMode'])) {
    $_COOKIE['MODX_themeMode'] = '';
}

$userlang    = $modx->getConfig('manager_language');
$_customlang = include MODX_BASE_PATH . 'assets/modules/clientsettings/lang.php';
$title       = isset($_customlang[$userlang]) ? $_customlang[$userlang] : reset($_customlang);
$_lang       = [];

include MODX_MANAGER_PATH . 'includes/lang/' . $userlang . '.inc.php';

$richtextinit  = [];
$defaulteditor = $modx->getconfig('which_editor');

$richtextparams = [
    'editor'   => $defaulteditor,
    'elements' => [],
    'options'  => [],
];
    
foreach ($tabs as $tab) {
    foreach ($tab['settings'] as $field => $options) {
        if ($options['type'] != 'richtext') {
            continue;
        }

        $editor    = $defaulteditor;
        $tvoptions = [];

        if (!empty($options['options'])) {
            $tvoptions = array_merge($tvoptions, $options['options']);
        }

        if (!empty($options['elements'])) {
            $tvoptions = array_merge($tvoptions, $modx->parseProperties($options['elements']));
        }

        if (!empty($tvoptions) && isset($tvoptions['editor'])) {
            $editor = $tvoptions['editor'];
        };

        $richtextparams['elements'][] = 'tv' . $field;
        $richtextparams['options']['tv' . $field] = $tvoptions;
    }
}

if (!empty($richtextparams)) {
    $richtextinit = $modx->invokeEvent('OnRichTextEditorInit', $richtextparams);

    if (is_array($richtextinit)) {
        $richtextinit = implode($richtextinit);
    }
}

$picker = [
    'yearOffset' => $modx->getConfig('datepicker_offset'),
    'format'     => $modx->getConfig('datetime_format') . ' hh:mm:00',
];

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
                <div class="btn-group dropdown">
                    <a id="Button1" class="btn btn-success" href="javascript:;" onclick="save_settings();">
                        <i class="fa fa-floppy-o"></i><span><?= $_lang['save'] ?></span>
                    </a>

                    <span class="btn btn-success plus dropdown-toggle"></span>

                    <select id="stay" name="stay">
                        <option id="stay2" value="2" <?= $stay == '2' ? ' selected="selected"' : '' ?>><?= $_lang['stay'] ?></option>
                        <option id="stay3" value="" <?= $stay == '' ? ' selected="selected"' : '' ?>><?= $_lang['close'] ?></option>
                    </select>
                </div>

                <a id="Button5" class="btn btn-secondary" href="<?= $managerPath ?>index.php?a=2">
                    <i class="fa fa-times-circle"></i><span><?= $_lang['cancel'] ?></span>
                </a>
            </div>
        </div>

        <div class="sectionBody" id="settingsPane">
            <div class="tab-pane" id="documentPane">
                <script type="text/javascript">
                    var tpSettings = new WebFXTabPane(document.getElementById('documentPane'), <?= ($modx->getConfig('remember_last_tab') == 1 ? 'true' : 'false') ?> );
                </script> 

                <?php foreach ($tabs as $name => $tab): ?>
                    <div class="tab-page" id="tab_<?= $name ?>">
                        <h2 class="tab"><?= $tab['caption'] ?></h2>
            
                        <script type="text/javascript">
                            tpSettings.addTabPage(document.getElementById('tab_<?= $name ?>'));
                        </script>
            
                        <table border="0" cellspacing="0" cellpadding="3" style="font-size: inherit; line-height: inherit;">
                            <?php if (!empty($tab['introtext'])): ?>
                                <tr>
                                    <td class="warning" nowrap="" colspan="2">
                                        <?= $tab['introtext'] ?>
                                        <div class="split" style="margin-bottom: 20px; margin-top: 10px;"></div>
                                    </td>
                                </tr>
                            <?php endif; ?>

                            <?php foreach ($tab['settings'] as $field => $options): ?>
                                <?php if ($options['type'] == 'divider'): ?>
                                    <tr>
                                        <td colspan="2">
                                            <h4 style="margin-top: 20px;"><?= $options['caption'] ?></h4>
                                        </td>
                                    </tr>
                                <?php else: ?>
                                    <tr>
                                        <td class="warning" nowrap="">
                                            <?php if ($options['type'] === 'title'): ?>
                                                <div style="font-size:120%;padding:20px 0 10px;font-weight:bold;">
                                                    <?= $options['caption'] ?>
                                                </div>
                                            <?php else: ?>
                                                <?= $options['caption'] ?> <br>
                                                <small>[(<?= $params['prefix'] . $field ?>)]</small>
                                            <?php endif; ?>
                                        </td>

                                        <td data-type="<?= $options['type'] ?>">

                                            <?php if ($options['type'] !== 'title'): ?>

                                                <?php
                                                    $value = isset($modx->config[$params['prefix'] . $field]) ? $modx->config[$params['prefix'] . $field] : false;

                                                    $row = [
                                                        'type'         => $options['type'],
                                                        'name'         => $field,
                                                        'caption'      => $options['caption'],
                                                        'id'           => $field,
                                                        'default_text' => isset($options['default_text']) && $value === false ? $options['default_text'] : '',
                                                        'value'        => $value,
                                                        'elements'     => isset($options['elements']) ? $options['elements'] : '',
                                                    ];
                                                ?>

                                                <?= renderFormElement(
                                                    $row['type'],
                                                    $row['name'],
                                                    '',
                                                    $row['elements'],
                                                    $row['value'] !== false ? $row['value'] : $row['default_text'],
                                                    isset($options['style']) ? 'style="' . $options['style'] . '"' : '',
                                                    $row
                                                ); ?>
                                            <?php endif; ?>

                                            <?php if (isset($options['note'])): ?>
                                                <div class="comment">
                                                    <?= $options['note'] ?>
                                                </div>
                                            <?php endif; ?>
                                        </td>
                                    </tr>
                                <?php endif; ?>

                                <?php if ($options['type'] !== 'title'): ?>
                                    <tr>
                                        <td colspan="2"><div class="split"></div></td>
                                    </tr>
                                <?php endif; ?>
                            <?php endforeach; ?>
                        </table>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
    </form>

    <?= $richtextinit ?>
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

?>

<?= $modx->manager->loadDatePicker($modx->getConfig('mgr_date_picker_path')) ?>

<script>
    jQuery('input.DatePicker').each(function() {
        new DatePicker(this, {
            yearOffset: <?= $picker['yearOffset'] ?>,
            format:     '<?= $picker['format'] ?>',
            dayNames:   <?= $_lang['dp_dayNames'] ?>,
            monthNames: <?= $_lang['dp_monthNames'] ?>,
            startDay:   <?= $_lang['dp_startDay'] ?> 
        });
    });

    function save_settings() {
        documentDirty = false;
        jQuery(document.settings).submit();
    }
</script>

<?php include_once MODX_MANAGER_PATH . 'includes/footer.inc.php'; ?>
