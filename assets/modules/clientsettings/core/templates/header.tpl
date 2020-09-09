<h1>
    <i class="fa <?= $head['icon'] ?>"></i><?= $head['caption'] ?>
</h1>

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

            <?php if ($this->manager['role'] == 1 && empty($_GET['editor'])): ?>
                <a id="Button5" class="btn btn-secondary" href="<?= $managerPath ?>index.php?a=112&id=<?= $mid ?>&type=<?= $params['menu'] ?>&editor=1">
                    <i class="fa fa-cog"></i><span><?= $_lang['cs.editor'] ?></span>
                </a>
            <?php endif; ?>

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
