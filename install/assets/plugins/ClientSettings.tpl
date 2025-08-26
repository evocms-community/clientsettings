/**
 * ClientSettings
 *
 * Creates menu item for user module ClientSettings
 *
 * @category    plugin
 * @version     2.2.1
 * @author      mnoskov
 * @internal    @events OnManagerMenuPrerender
 * @internal    @modx_category Manager and Admin
 */
//<?php

if ($modx->event->name == 'OnManagerMenuPrerender'):
	require_once MODX_BASE_PATH . 'assets/modules/clientsettings/core/src/ClientSettings.php';
	$cs   = new ClientSettings($params);
	$mid  = $cs->getModuleId();
	$lang = $cs->loadLang();
	$tabs = $cs->loadStructure();
	$permissionAccessInt = -1;
	if($modx->hasPermission('exec_module')):
		// check if user has access permission, except admins
		if($_SESSION['mgrRole']!=1):
			$rs = $modx->db->select(
				'sma.usergroup,mg.member',
				$modx->getFullTableName("site_module_access") . " sma LEFT JOIN " . $modx->getFullTableName("member_groups") . " mg ON mg.user_group = sma.usergroup AND member='" . $modx->getLoginUserID()."'",
				"sma.module = '{$mid}'"
			);
			//initialize permission to -1, if it stays -1 no permissions
			//attached so permission granted
			while ($row = $modx->db->getRow($rs)):
				if($row["usergroup"] && $row["member"]):
					//if there are permissions and this member has permission, ofcourse
					//this is granted
					$permissionAccessInt = 1;
				elseif ($permissionAccessInt==-1):
					//if there are permissions but this member has no permission and the
					//variable was still in init state we set permission to 0; no permissions
					$permissionAccessInt = 0;
				endif;
			endwhile;
		else:
			$permissionAccessInt = 1;
		endif;
		if($permissionAccessInt):
			if (!empty($tabs)):
				$menuparams = ['client_settings', 'main', '<i class="fa fa-cog"></i>' . $lang['cs.module_title'], 'index.php?a=112&id=' . $mid . '&type=default', $lang['cs.module_title'], '', '', 'main', 0, 100, ''];
				if (count($tabs) > 1):
					$menuparams[3] = 'javscript:;';
					$menuparams[5] = 'return false;';
					$sort = 0;
					$params['menu']['client_settings_main'] = ['client_settings_main', 'client_settings', '<i class="fa fa-cog"></i>' . $lang['cs.module_title'], 'index.php?a=112&id=' . $mid . '&type=default', $lang['cs.module_title'], '', '', 'main', 0, $sort, ''];
					foreach ($tabs as $alias => $item):
						if ($alias != 'default'):
							$params['menu']['client_settings_' . $alias] = ['client_settings_' . $alias, 'client_settings', '<i class="fa ' . (isset($item['menu']['icon']) ? $item['menu']['icon'] : 'fa-cog') . '"></i>' . $item['menu']['caption'], 'index.php?a=112&id=' . $mid . '&type=' . $alias, $item['menu']['caption'], '', '', 'main', 0, $sort += 10, ''];
						endif;
					endforeach;
				endif;
				$params['menu']['client_settings'] = $menuparams;
				$modx->event->output(serialize($params['menu']));
			endif;
		endif;
	endif;
	return;
endif;
