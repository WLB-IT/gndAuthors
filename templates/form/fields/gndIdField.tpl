{**
* This template uses the lobid API to fetch GND data of authors 
* and autosuggest them when adding a contributor.
* A special GND-ID field is added to the contributor form.
*}

<!-- GND ID -->
{fbvFormSection title="plugins.generic.gndid.field.title"}
	{fbvElement type="search" label="plugins.generic.gndid.field.desc" id="authorGndId" value=$authorGndId maxlength="255" inline=true size=$fbvStyles.size.MEDIUM}
{/fbvFormSection}
<!-- /GND ID -->

<script>
$(document).ready(function () {ldelim}

// Initialize variables of the three fields.
var searchGivenName = 'input[id^="givenName-"]';
var searchSurname = 'input[id^="familyName-"]';
var searchGndId = 'input[id^="authorGndId-"]';
var autocompleteFields = [searchGivenName, searchSurname,  searchGndId];


/*
Due to a bug in Chrome autocomplete="off" does not work.
Therefore, this is a workaround to disable Chrome's autocomplete.
*/
$(searchGivenName).attr('type', 'search');
$(searchSurname).attr('type', 'search');


    // Ajax call to lobid API for each field.
	$(autocompleteFields).each(function(index, value) {ldelim}
    $(value).autocomplete({ldelim}
        source: function (request, response) {ldelim}
            $.ajax({ldelim}
                url: '//lobid.org/gnd/search',
                dataType: 'jsonp',
                data: {ldelim}
                    q: request.term,
                    format: "json:suggest",
                    size: "30",
                    filter: "type:Person"
                {rdelim},

                // When success, store info in array and return.
                success: function (data) {ldelim}


                    // Response: wrangle data to show last or first name depending on field.
                    response($.map(data, function (elem) {ldelim}

                        // Split label.
                        var splitLabel = elem.label.split('|');

                        // Slice extra info in label if present.
                        var additionalData = splitLabel.length > 1 ? splitLabel.slice(1).join(' | ') : '';
                        
                        // Get the full name and split it.
                        var fullName = splitLabel[0];
                        var fullNameSplit = fullName.includes(',') ? fullName.split(',') : [fullName];

                        // Adjust view of data depeding on field.
                        if (searchGivenName === value) {ldelim}

                        // Move first name to the front
                        var newName = fullNameSplit.length > 1 ? fullNameSplit[1].trim() + ', ' + fullNameSplit[0].trim() : fullNameSplit[0].trim();
                        
                        // Merge data.
                        var responseString = (newName + ' | ' + additionalData + ' | ' + elem.id).replace('|  |', '|');
                      
                        {rdelim} else {ldelim}

                        // In other fields, do not move first name to front.
                        var additionalData = elem.label.split('|').slice(1, 3).join(' | ');
                        var responseString = (fullName + ' | ' + additionalData + ' | ' + elem.id).replace('|  |', '|');
                        {rdelim} 

                        return responseString;
                    {rdelim}));
                {rdelim}
            {rdelim});          
        {rdelim},
        minLength: 2,
        autoFocus: true, 

		// Select item.
		select: function (event, ui) {ldelim}

        /*
         Prevent the input box from selecting the response item.
         Use the values below instead.
        */ 
        event.preventDefault();

        // Split the result.
        var result = ui.item.label.split("|");

        // Get data according to field, trim whitespace.
        if (searchGivenName === value) {ldelim}
        
        var firstName = result[0].split(',')[0].trim();
        var lastName = result[0].includes(',')  ? result[0].split(',')[1].trim() : '';
        var gndId = result.slice(-1)[0].trim();
     
        {rdelim} else {ldelim}

        var firstName = result[0].includes(',') ? result[0].split(',')[1].trim() : result[0].trim();
		var lastName = result[0].includes(',') ? result[0].split(',')[0].trim() : '';
        var gndId = result.slice(-1)[0].trim();

		{rdelim}

        // Fill in all three fields automatically upon select.
        $(searchGivenName).val(firstName);
		$(searchSurname).val(lastName);
        $(searchGndId).val(gndId);

      {rdelim}
    {rdelim});
	{rdelim});
{rdelim});
</script>
