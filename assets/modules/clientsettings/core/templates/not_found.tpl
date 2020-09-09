<div class="tab-page">
    <div class="container-body">
        Configuration not found. Rename <code><?= $path ?>*.sample</code> files or create new ones.<br>

        <?php if ($this->manager['role'] == 1): ?>
            Also you can create new tabs using very nice <a href="<?= $managerPath ?>index.php?a=112&id=<?= $mid ?>&editor=1">editor</a>.
        <?php endif; ?>
    </div>
</div>
