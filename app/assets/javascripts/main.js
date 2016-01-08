var ready = function() {
    $("#ajax-loader").hide();
  ADDRESSES.requestTriggerZipcode();

  INTEREST.disableButtonOnSubmit();

  VALIDATION.eventsValidate();

  LOGIN.validateFormOnSubmit();

  MASKS.addMasks();

  NGO.validateFormOnSubmit();

  OPPORTUNITIES.validateFormOnSubmit();
  OPPORTUNITIES.getCausesChecked();
  OPPORTUNITIES.getCitiesChecked();
  OPPORTUNITIES.getRecurrentChecked();

  PASS_RESETS.validateFormResetPassOnSubmit();

  VOLUNTEER.validateFormOnSubmit();
}

$(document).ready(ready);
$(document).on('page:load', ready);