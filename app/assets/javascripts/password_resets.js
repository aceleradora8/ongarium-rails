var PASS_RESETS = PASS_RESETS || {}

PASS_RESETS.validateFormResetPassOnSubmit = function validateFormResetPass() {
  $("#form-password-reset").submit(function() {
    validatePassword = VALIDATION.validatePassword();
    validatePasswordConfirmation = VALIDATION.validatePasswordConfirmation();
    if (VALIDATION.hasError()) {
      return false;
      }
      VALIDATION.disableButtonOnSubmit();
      return true;
  });
};
