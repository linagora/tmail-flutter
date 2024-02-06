const i18n = {};
const languageDefault = 'en';

/**
 * 
 * @param {String} language 
 * @returns {boolean}
 */
function isValidUserLanguage(language) {
  if (language == null || language == undefined) {
    return false;
  }
  return true;
}

function getUserLanguage() {
  console.info(`[Twake Mail] Current Language: `, navigator.language);
  if (isValidUserLanguage(navigator.language)) {
    return languageDefault;
  }
  return navigator.language.split('-')[0];
}

async function loadLanguageResources() {
  try {
    const language = getUserLanguage();
    const response = await fetch(`/i18n/${language}.json`);
    const data = await response.json();
    i18n[language] = data;
    console.info(`[Twake Mail] Successfully loaded ${language} resources:`, i18n[language]);
  } catch (error) {
    console.error(`[Twake Mail] Error loading ${language} resources:`, error);
  }
}

document.addEventListener('DOMContentLoaded', function () {
  const language = getUserLanguage();
  document.getElementById('banner-title-id').textContent = i18n[language].title;
  document.getElementById('banner-description-id').textContent = i18n[language].description;
  document.getElementById('open-button-id').textContent = i18n[language].open;
});