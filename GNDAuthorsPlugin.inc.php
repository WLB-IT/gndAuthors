<?php

import('lib.pkp.classes.plugins.GenericPlugin');

class GNDAuthorsPlugin extends GenericPlugin {

	/**
	 * Provide a name for this plugin
	 *
	 * The name will appear in the plugins list where editors can
	 * enable and disable plugins.
	 */
	public function getDisplayName() {
		return __('plugins.generic.gndAuthors.title');
	}

	/**
	 * Provide a description for this plugin
	 *
	 * The description will appear in the plugins list where editors can
	 * enable and disable plugins.
	 */
	public function getDescription() {
		return __('plugins.generic.gndAuthors.desc');
	}

	/**
	 * Register the plugin and hook into functions to change.
	 */
	public function register($category, $path, $mainContextId = null) {

		$success = parent::register($category, $path);

		// Only hook into functions if the plugin is registered and enabled.
		if ($success && $this->getEnabled()) {

			// Use hook to overwrite template before it is rendered and displayed in the submission and quicksubmit steps.
			//HookRegistry::register('TemplateResource::getFilename', array($this, '_overridePluginTemplates'));

			// Insert additional GND ID field, get save user-entred values, save in DB.
			HookRegistry::register('Schema::get::author', array($this, 'addToSchema'));
			HookRegistry::register('authorform::initdata', array($this, 'gndInitData'));
			HookRegistry::register('Common::UserDetails::AdditionalItems', array($this, 'addGndIdField'));
			HookRegistry::register('authorform::execute', array($this, 'collectGndIdField'));
			HookRegistry::register('authordao::getAdditionalFieldNames', array($this, 'addGndIdToDao'));
		}

		return $success;
	}


	/**
	 * Add authorGndId to author_settings DB schema.
	 * @param $hookName string
	 * @param $params array
	 */
	public function addToSchema($hookName, $args) {

		$schema = $args[0];
		$schema->properties->authorGndId = (object) [
			'type' => 'string',
			'multilingual' => false,
			'apiSummary' => true,
			'validation' => ['nullable']
		];
		return false;
	}


	/**
	 * Init GND ID in the author form to display.
	 * @param $hookName string
	 * @param $params array
	 */
	function gndInitData($hookName, $params) {

		// Fetch form and author.
		$form = $params[0];
		$author = $form->getAuthor();

		// Initialize Data.
		if ($author) {
			$form->setData('authorGndId', $author->getData('authorGndId'));
		}

		return false;
	}

	/**
	 * Add GND ID field to author form.
	 * @param $hookName string
	 * @param $params array
	 */
	public function addGndIdField($hookName, $params) {

		// Get smarty and template.
		$smarty = $params[1];
		$template = $params[2];

		// Fetch new field.
		$template .= $smarty->display($this->getTemplateResource('/form/fields/gndIdField.tpl'));
		return false;
	}

	/**
	 * Get user-entered variables of the GND ID field.
	 * @param $hookName string
	 * @param $params array
	 */
	public function collectGndIdField($hookName, $params) {

		// Fetch necessary variables: form and author.
		$form = $params[0];
		$author = $form->getAuthor();

		// Read user-entered value.
		$form->readUserVars(array('authorGndId'));

		// Get value of GND ID field.
		$authorGndId = $form->getData('authorGndId');

		// Set data.
		if ($authorGndId) {
			$author->setData('authorGndId', $authorGndId);
		}

		return false;
	}

	/**
	 * For storage: Get a list of additional field names to store in authordao.
	 * @param $hookName
	 * @param $params
	 */
	function addGndIdToDao($hookName, $params) {
		$fields = &$params[1];
		$fields[] = 'authorGndId';
		return false;
	}
}
