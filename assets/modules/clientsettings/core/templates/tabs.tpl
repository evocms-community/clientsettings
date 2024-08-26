<style>
	.clSettings .hr { display:flex; flex-wrap:nowrap; align-items: center; margin: 0 -0.25rem;}
	.clSettings .hr:after {content:''; border-bottom: #ddd 1px solid; margin: 1rem 0; width:100%; }
	.clSettings .col { display:flex; flex-basis: 100%; align-items: flex-start;}
	.clSettings .col .row{ flex-grow: 1; padding-top: .5rem; transition:background .5s ease;}
	.clSettings .col .row:hover {background:#e8ebef;}
	.clSettings .col .warning small {display: flex;}
	@media (min-width: 576px){
	.clSettings .col[class*='col-sm-'] >.row > [class*='col-']{ max-width:100%; min-width:100%;}
	.clSettings .col[class*='col-sm-'] .warning small {display: inline-flex;}}
	@media (min-width: 768px){
	.clSettings .col[class*='col-md-'] >.row > [class*='col-']{ max-width:100%; min-width:100%;}
	.clSettings .col[class*='col-md-'] .warning small {display: inline-flex;}
	 }
	@media (min-width: 992px){
	.clSettings .col[class*='col-lg'] >.row > [class*='col-']{ max-width:100%; min-width:100%;}
	.clSettings .col[class*='col-lg-'] .warning small {display: inline-flex;}
	}
	@media (min-width: 1200px){
	.clSettings .col[class*='col-xl-'] >.row > [class*='col-']{ max-width:100%; min-width:100%;}
	.clSettings .col[class*='col-xl-'] .warning small {display: inline-flex;}
	}
    .image_for_field[data-image] { display: block; content: ""; width: 120px; height: 120px; margin: .1rem .1rem 0 0; border: 1px #ccc solid; background: #fff 50% 50% no-repeat; background-size: contain; cursor: pointer }
    .image_for_field[data-image=""] { display: none }
</style>
<script>
    function evoRenderTvImageCheck (a) {
        var b = document.getElementById('image_for_' + a.target.id),
            c = new Image
        a.target.value ? (c.src = (a.target.value.search(/^https?:\/\//i) < 0 ? "<?php echo evo()->getConfig('site_url')?>" : '') + a.target.value, c.onerror = function () {
            b.style.backgroundImage = '', b.setAttribute('data-image', '')
        }, c.onload = function () {
            b.style.backgroundImage = 'url(\'' + this.src + '\')', b.setAttribute('data-image', this.src)
        }) : (b.style.backgroundImage = '', b.setAttribute('data-image', ''))
    }
</script>
<?php foreach ($tabs as $name => $tab): ?>
    <div class="tab-page clSettings" id="tab_<?= $name ?>">
        <h2 class="tab"><?= $tab['caption'] ?></h2>

        <script type="text/javascript">
            tpSettings.addTabPage(document.getElementById('tab_<?= $name ?>'));
        </script>
        <div class="row  ml-2 mr-2" style="font-size: inherit; line-height: inherit;">
            <?php if (!empty($tab['introtext'])): ?>
                    <div class="warning col-12">
                        <div class="text-nowrap mr-1"><?= $tab['introtext'] ?></div>
                    </div>
            <?php endif; ?>

            <?php foreach ($tab['settings'] as $field => $options): ?>
                <?php if ($options['type'] == 'divider'): ?>
                        <div class="col-12 mb-2">
                            <h4 class="hr text-nowrap"><div class="text-nowrap mr-3"><?= $options['caption'] ?></div></h4>
                        </div>
                <?php else: ?>
					<div class="col  <?= $options['class'] ?? '' ?> ">
						<div class="row">
							<div class="warning col-sm-4 col-md-3 col-lg-2 h5">
								<?php if ($options['type'] === 'title'): ?>
									<div class="text-nowrap mb-1 ">
										<?= $options['caption'] ?>
									</div>
								<?php else: ?>
									<?= $options['caption'] ?>
									<small class="text-nowrap text-black-50 pt-1">[(<?= $params['prefix'] . $field ?>)]</small>
								<?php endif; ?>
							</div>

							<div class="col-sm-8 col-md-9 col-lg-10 mb-2" data-type="<?= $options['type'] ?>">
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
							</div>
						</div>
					</div>
                <?php endif; ?>

            <?php endforeach; ?>
        </div>
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
            <script src="<?= MODX_SITE_URL . 'assets/modules/clientsettings/core/js/tvimage.js' ?>"></script>
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
