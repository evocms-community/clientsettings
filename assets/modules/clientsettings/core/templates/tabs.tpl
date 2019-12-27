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

<?= $richtextinit ?>

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
            <script src="<?= MODX_SITE_URL . 'assets/plugins/managermanager/widgets/showimagetvs/jquery.ddMM.mm_widget_showimagetvs.js' ?>"></script>
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
        document.settings.save.click();
    }
</script>

        