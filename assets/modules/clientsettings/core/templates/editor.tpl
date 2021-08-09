<div class="tab-page" id="tab_editor">
    <h2 class="tab"><?= $_lang['cs.editor'] ?></h2>

    <script type="text/javascript">
        tpSettings.addTabPage(document.getElementById('tab_editor'));
    </script>

    <?php if (empty($structure['menu']['alias']) || !empty($structure['menu']['alias']) && $structure['menu']['alias'] != 'default'): ?>
        <div>
            <label><?= $_lang['resource_opt_menu_title'] ?></label>
            <input class="form-control" name="struct[menu][caption]" value="<?= !empty($structure['menu']['caption']) ? htmlentities($structure['menu']['caption']) : '' ?>">
        </div>

        <div>
            <label><?= $_lang['alias'] ?></label>
            <input class="form-control" name="struct[menu][alias]" value="<?= !empty($structure['menu']['alias']) ? htmlentities($structure['menu']['alias']) : '' ?>">
        </div>
        <br>
    <?php else: ?>
        <input type="hidden" name="struct[menu][alias]" value="default">
    <?php endif; ?>

    <?php foreach ($structure['tabs'] as $key => $tab): ?>
        <div class="tab-setting">
            <a href="#" class="add_tab" title="<?= $_lang['cm_add_new_category'] ?>"><i class="fa fa-plus-circle"></i></a>
            <a href="#" class="remove_tab" title="<?= $_lang['delete'] ?>"><i class="fa  fa-minus-circle"></i></a>
            <div class="tab-caption">
                <label><?= $_lang['resource_title'] ?></label>
                <input class="form-control caption" name="struct[tabs][<?= $key ?>][caption]" value="<?= $tab['caption'] ?>">
            </div>
            <div class="tab-introtext">
                <label><?= $_lang['resource_summary'] ?></label>
                <input class="form-control introtext" name="struct[tabs][<?= $key ?>][introtext]" value="<?= $tab['introtext'] ?>">
            </div>
            <br>

            <div class="table-responsive">
                <table class="table data" cellpadding="1" cellspacing="1">
                    <thead>
                        <tr>
                            <td class="tableHeader"><?= $_lang['name'] ?></td>
                            <td class="tableHeader"><?= $_lang['resource_title'] ?></td>
                            <td class="tableHeader"><?= $_lang['type'] ?></td>
                            <td class="tableHeader"><?= $_lang['resource_description'] ?></td>
                            <td class="tableHeader"><?= $_lang['tmplvars_elements'] ?></td>
                            <td class="tableHeader"><?= $_lang['set_default'] ?></td>
                            <td class="tableHeader" width="1%"> </td>
                        </tr>
                    </thead>
                    <tbody class="sort-str">
                        <?php $i = 0; ?>
                        <?php foreach ($tab['settings'] as $field => $value): ?>
                            <tr>
                                <td class="tableHeader">
                                    <input class="form-control" name="struct[tabs][<?= $key ?>][settings][<?= $i ?>][field]" value="<?= htmlspecialchars($field) ?>">
                                </td>
                                <td class="tableHeader">
                                    <input class="form-control" name="struct[tabs][<?= $key ?>][settings][<?= $i ?>][caption]" value="<?= htmlspecialchars($value['caption']) ?>">
                                </td>
                                <td class="tableHeader">
                                    <select size="1" class="form-control" name="struct[tabs][<?= $key ?>][settings][<?= $i ?>][type]">
                                        <optgroup label="Standard Type">
                                            <option value="text" <?= ($value['type'] == '' || $value['type'] == 'text' ? "selected='selected'" : "") ?>>Text</option>
                                            <option value="textarea" <?= ($value['type'] == 'textarea' ? "selected='selected'" : "") ?>>Textarea</option>
                                            <option value="textareamini" <?= ($value['type'] == 'textareamini' ? "selected='selected'" : "") ?>>Textarea (Mini)</option>
                                            <option value="richtext" <?= ($value['type'] == 'richtext' || $value['type'] == 'htmlarea' ? "selected='selected'" : "") ?>>RichText</option>
                                            <option value="dropdown" <?= ($value['type'] == 'dropdown' ? "selected='selected'" : "") ?>>DropDown List Menu</option>
                                            <option value="listbox" <?= ($value['type'] == 'listbox' ? "selected='selected'" : "") ?>>Listbox (Single-Select)</option>
                                            <option value="listbox-multiple" <?= ($value['type'] == 'listbox-multiple' ? "selected='selected'" : "") ?>>Listbox (Multi-Select)</option>
                                            <option value="option" <?= ($value['type'] == 'option' ? "selected='selected'" : "") ?>>Radio Options</option>
                                            <option value="checkbox" <?= ($value['type'] == 'checkbox' ? "selected='selected'" : "") ?>>Check Box</option>
                                            <option value="image" <?= ($value['type'] == 'image' ? "selected='selected'" : "") ?>>Image</option>
                                            <option value="file" <?= ($value['type'] == 'file' ? "selected='selected'" : "") ?>>File</option>
                                            <option value="url" <?= ($value['type'] == 'url' ? "selected='selected'" : "") ?>>URL</option>
                                            <option value="email" <?= ($value['type'] == 'email' ? "selected='selected'" : "") ?>>Email</option>
                                            <option value="number" <?= ($value['type'] == 'number' ? "selected='selected'" : "") ?>>Number</option>
                                            <option value="date" <?= ($value['type'] == 'date' ? "selected='selected'" : "") ?>>Date</option>
                                        </optgroup>
                                        <optgroup label="Custom Type">
                                            <option value="custom_tv" <?= ($value['type'] == 'custom_tv' ? "selected='selected'" : "") ?>>Custom Input</option>
                                            <?php
                                                $custom_tvs = scandir(MODX_BASE_PATH . 'assets/tvs');
                                                foreach ($custom_tvs as $ctv) {
                                                    if (strpos($ctv, '.') !== 0 && $ctv != 'index.html') {
                                                        $selected = ($value['type'] == 'custom_tv:' . $ctv ? "selected='selected'" : "");
                                                        echo '<option value="custom_tv:' . $ctv . '"  ' . $selected . '>' . $ctv . '</option>';
                                                    }
                                                }
                                            ?>
                                        </optgroup>
                                    </select>
                                </td>
                                <td class="tableHeader">
                                    <input class="form-control" name="struct[tabs][<?= $key ?>][settings][<?= $i ?>][note]" value="<?= htmlspecialchars($value['note']) ?>">
                                </td>
                                <td class="tableHeader">
                                    <input class="form-control" name="struct[tabs][<?= $key ?>][settings][<?= $i ?>][elements]" value="<?= htmlspecialchars($value['elements']) ?>">
                                </td>
                                <td class="tableHeader">
                                    <input class="form-control" name="struct[tabs][<?= $key ?>][settings][<?= $i ?>][default_text]" value="<?= htmlspecialchars($value['default_text']) ?>">
                                </td>
                                <td class="tableHeader" width="1%">
                                    <ul class="elements_buttonbar">
                                        <li><a title="Добавить" class="add_field"><i class="fa fa-plus fa-fw"></i></a></li>
                                        <li><a title="Удалить" class="remove_field"><i class="fa fa-minus fa-fw"></i></a></li>
                                    </ul>
                                </td>
                            </tr>
                            <?php $i++; ?>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    <?php endforeach; ?>
</div>

<script>
    var rowsPrefix = '<?= $prefix ?>';

    function save_settings() {
        documentDirty = false;
        document.settings.save.click();
    }
</script>

<link href="<?= $modx->getConfig('base_url') ?>assets/modules/clientsettings/core/css/editor.css?<?= $version ?>" rel="stylesheet">
<script src="<?= $modx->getConfig('base_url') ?>assets/modules/clientsettings/core/js/editor.js?<?= $version ?>"></script>
