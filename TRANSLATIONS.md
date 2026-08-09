## Translations

### Prerequisites

Make sure you have the package `gettext` installed on your system, as it is required for managing translations.

### I18n helper script

The widget comes with a helper script (`bin/i18n`) to manage translations:

1. **Extract translatable strings** from the source code:
   ```sh
   ./bin/i18n extract
   ```
   Creates/updates the translation template file (`src/translate/template.pot`) and updates existing `.po` files.

1. **Check translation status**:
   ```sh
   ./bin/i18n check
   ```
   Check if translations template is up to date and shows how many strings are untranslated in each language file.

1. **Initialize a new language**:
   ```sh
   ./bin/i18n init <lang_code>
   ```
   For example, `./bin/i18n init fr` creates a new French translation file.

1. **Compile translations**:
   ```sh
   ./bin/i18n compile
   ```
   This compiles all `.po` files into `.mo` files that the widget can use.

### Contributing Translations

1. Create or edit a `.po` file in the `src/translate/` directory.
1. Compile the translations to verify they work correctly.
1. Submit a pull request with your changes to the `src/translate/` directory, do not include the compiled `.mo` files, as they will be generated automatically during the build process.