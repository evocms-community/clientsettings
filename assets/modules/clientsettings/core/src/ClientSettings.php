<?php

class ClientSettings
{
    const VERSION = '2.1.2';

    private $corePath;
    private $params = [];
    private $lang = null;
    private $manager = [];

    public function __construct($params = [])
    {
        if (empty($params['config_path'])) {
            $params['config_path'] = __DIR__ . '/../../config/';
        } else {
            $params['config_path'] = MODX_BASE_PATH . trim($params['config_path'], '/');
        }

        $this->params = $params;
        $this->params['config_path'] = rtrim(realpath($this->params['config_path']), '/') . '/';
        $this->params['menu'] = isset($_GET['type']) && is_string($_GET['type']) ? $_GET['type'] : 'default';

        $this->corePath = rtrim(realpath(__DIR__ . '/../'), '/') . '/';

        $evo = EvolutionCMS();
        $manager_id = $evo->getLoginUserID('mgr');
        $this->manager = $evo->getUserInfo($manager_id);
    }

    public function processRequest()
    {
        $structure = $this->loadStructure($this->params['menu']);

        if (isset($_GET['editor'])) {
            if ($_SERVER['REQUEST_METHOD'] == 'POST') {
                return $this->saveConfiguration($_POST);
            }

            echo $this->renderEditor($structure);
            return;
        }

        if ($_SERVER['REQUEST_METHOD'] == 'POST') {
            return $this->saveTabs($structure['tabs'], $_POST);
        }

        if (empty($structure['tabs'])) {
            echo $this->render('not_found', [
                'path' => $this->params['config_path'],
            ]);
        } else {
            echo $this->renderTabs($structure);
        }
    }

    public function loadStructure($menuitem = false)
    {
        $tabs = [];

        foreach (glob($this->params['config_path'] . '*.php') as $file) {
            $tab = include $file;

            if (!empty($tab) && is_array($tab)) {
                if ($this->manager['role'] != 1) {
                    if (isset($tab['role']) && $tab['role'] != $this->manager['role']) {
                        continue;
                    }

                    if (isset($tab['roles'])) {
                        if (!is_array($tab['roles'])) {
                            $tab['roles'] = array_map('trim', explode(',', $tab['roles']));
                        }

                        if (!in_array($this->manager['role'], $tab['roles'])) {
                            continue;
                        }
                    }
                }

                $alias = pathinfo($file, PATHINFO_FILENAME);

                if (!isset($tab['menu'])) {
                    $tab['menu'] = [
                        'alias' => 'default',
                    ];
                }

                $menualias = $tab['menu']['alias'];

                if (!isset($tabs[$menualias])) {
                    $tabs[$menualias] = [
                        'menu' => $tab['menu'],
                        'tabs' => [],
                    ];
                }

                unset($tab['menu']);
                $tabs[$menualias]['tabs'][$alias] = $tab;
            }
        }

        if ($menuitem) {
            if (isset($tabs[$menuitem])) {
                return $tabs[$menuitem];
            }

            return [];
        }

        return $tabs;
    }

    private function saveTabs($tabs, $data)
    {
        $modx = EvolutionCMS();
        $fields = [];

        foreach ($tabs as $tab) {
            foreach (array_keys($tab['settings']) as $field) {
                $postfield = 'tv' . $field;

                $type = $tab['settings'][$field]['type'];

                if (isset($data[$postfield])) {
                    $value = $data[$postfield];
                } else if (isset($tab['settings'][$field]['default_value'])) {
                    $value = $tab['settings'][$field]['default_value'];
                } else {
                    $value = '';
                }

                switch ($type) {
                    case 'url':
                        if ($data[$postfield . '_prefix'] != '--') {
                            $value = str_replace(array (
                                "feed://",
                                "ftp://",
                                "http://",
                                "https://",
                                "mailto:"
                            ), "", $value);
                            $value = $data[$postfield . '_prefix'] . $value;
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

                $fields[$field] = [$this->params['prefix'] . $field, $value];
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

        if ($_REQUEST['stay'] == 2) {
            $modx->sendRedirect('index.php?a=112&id=' . $_GET['id'] . '&type=' . $this->params['menu']);
        } else {
            $modx->sendRedirect('index.php?a=7&r=10');
        }
    }

    private function saveConfiguration($data)
    {
        if (isset($data['struct'])) {
            $alias = !empty($data['struct']['menu']['alias']) ? $data['struct']['menu']['alias'] : 'default';
            $files = new RecursiveDirectoryIterator($this->params['config_path'], FilesystemIterator::SKIP_DOTS);

            foreach ($files as $file) {
                //$file = $file->getRealPath();
                $config = include $file;
                $configAlias = !empty($config['menu']['alias']) ? $config['menu']['alias'] : 'default';

                if ($configAlias == $alias) {
                    unlink($file);
                }
            }

            $menu = null;

            if ($alias != 'default') {
                $menu = $data['struct']['menu'];
            }

            foreach ($data['struct']['tabs'] as $tabAlias => $tab) {
                $config = [
                    'caption'   => $tab['caption'] ? $tab['caption'] : 'Untitled tab',
                    'introtext' => $tab['introtext'],
                ];

                if (!empty($menu)) {
                    $config['menu'] = $menu;
                }

                foreach ($tab['settings'] as $setting) {
                    $f = $setting['field'];

                    if (!empty($f)) {
                        unset($setting['field']);
                        $config['settings'][$f] = $setting;
                    }
                }

                $text = '<?php' . PHP_EOL . 'return ' . var_export($config, true) . ';';
                file_put_contents($this->params['config_path'] . $tabAlias . '.php', $text);
            }
        }

        $modx = EvolutionCMS();

        if ($_REQUEST['stay'] == 2) {
            $modx->sendRedirect('index.php?a=112&id=' . $_GET['id'] . '&type=' . $this->params['menu'] . '&editor=1');
        } else {
            $modx->sendRedirect('index.php?a=7&r=10');
        }
    }

    public function getModuleId()
    {
        $modx = EvolutionCMS();
        return $modx->db->getValue($modx->db->select('id', $modx->getFullTablename('site_modules'), "name = 'ClientSettings'"));
    }

    private function renderEditor($structure)
    {
        if (empty($structure)) {
            $lang = $this->loadLang();

            $menu = '';
            if (!empty($_REQUEST['type'])) {
                $menu = mb_strtolower(preg_replace('/[^a-zA-Z0-9_-]+/', '', $_REQUEST['type'])) . '_';
            }

            $structure = [
                'menu' => [
                    'alias'   => 'default',
                    'caption' => $lang['cs.module_title'],
                    'icon'    => 'fa-cog',
                ],
                'tabs' => [
                    "{$menu}tab10" => [
                        'caption'   => 'Untitled tab',
                        'introtext' => '',
                        'settings'  => [
                            'untitled_field' => [
                                'caption'      => '',
                                'type'         => '',
                                'note'         => '',
                                'default_text' => '',
                            ],
                        ],
                    ],
                ],
            ];
        }

        return $this->render('editor', [
            'structure' => $structure,
            'prefix'    => !empty($menu) ? $menu : 'default_',
        ]);
    }

    private function renderTabs($structure)
    {
        $modx = EvolutionCMS();

        $richtextinit  = [];
        $defaulteditor = $modx->getconfig('which_editor');

        $richtextparams = [
            'editor'   => $defaulteditor,
            'elements' => [],
            'options'  => [],
        ];

        foreach ($structure['tabs'] as $tab) {
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

        return $this->render('tabs', [
            'tabs'         => $structure['tabs'],
            'richtextinit' => $richtextinit,
            'picker'       => $picker,
            'head'         => !empty($structure['menu']) && $structure['menu']['alias'] != 'default' ? $structure['menu'] : [],
        ]);
    }

    public function loadLang()
    {
        if ($this->lang === null) {
            $modx  = EvolutionCMS();
            $_lang = [];

            $aliases = [
                'bg' => 'bulgarian',
                'zh' => 'chinese',
                'cs' => 'czech',
                'da' => 'danish',
                'en' => 'english',
                'fi' => 'finnish',
                'fr' => 'francais-utf8',
                'de' => 'german',
                'he' => 'hebrew',
                'it' => 'italian',
                'jp' => 'japanese-utf8',
                'nl' => 'nederlands-utf8',
                'no' => 'norsk',
                'fa' => 'persian',
                'pl' => 'polish-utf8',
                'pt' => 'portuguese-br-utf8',
                'ru' => 'russian-UTF8',
                'es' => 'spanish-utf8',
                'sv' => 'svenska-utf8',
                'uk' => 'ukrainian'
            ];

            $userlang = $modx->getConfig('manager_language');

            if (isset($aliases[$userlang])) {
                include EVO_CORE_PATH . 'lang/' . $userlang . '/global.php';
                $userlang = $aliases[$userlang];
            } else {
                include MODX_MANAGER_PATH . 'includes/lang/' . $userlang . '.inc.php';
            }

            foreach ([$userlang, 'english'] as $l) {
                if (is_readable($this->corePath . 'lang/' . $l . '/cs.inc.php')) {
                    $lang = include $this->corePath . 'lang/' . $l . '/cs.inc.php';
                    break;
                }
            }

            $this->lang = array_merge($_lang, $lang);
        }

        return $this->lang;
    }

    private function render($template, $data = [])
    {
        global $content, $_style, $lastInstallTime, $modx_lang_attribute;
        $content['richtext'] = 1;

        if (!isset($_COOKIE['MODX_themeMode'])) {
            $_COOKIE['MODX_themeMode'] = '';
        }

        $modx   = EvolutionCMS();
        $managerPath = $modx->getManagerPath();
        $version = self::VERSION;
        $stay   = $_REQUEST['stay'];
        $_lang  = $this->loadLang();
        $params = $this->params;
        $mid    = $this->getModuleId();

        $data['head'] = array_merge([
            'caption' => $_lang['cs.module_title'],
            'icon'    => 'fa-cog',
        ], !empty($data['head']) ? $data['head'] : []);

        extract($data);
        setlocale(LC_NUMERIC, 'C');

        ob_start();

        include_once MODX_MANAGER_PATH . 'includes/header.inc.php';
        include $this->corePath . 'templates/header.tpl';
        include $this->corePath . 'templates/' . $template . '.tpl';
        include $this->corePath . 'templates/footer.tpl';
        include_once MODX_MANAGER_PATH . 'includes/footer.inc.php';

        return ob_get_clean();
    }
}
