(function($) {
    $(document).on('click', '.add_tab', function() {
        var tab = $('.tab-setting').eq(0).html();
        $(this).closest('.tab-setting').after('<div class="tab-setting new_tab">'+tab+'</div>');
        $('.new_tab input, .new_tab select').val('');
        var i = 0;
        $('.new_tab tbody tr').each(function() {
            if (i>0) $(this).remove();
            i = 1;
        });
        reset_index();

    });


    $(document).on('click', '.add_field', function() {
        var tr = $(this).closest('tr').html();
        $(this).closest('tr').after('<tr class="news_str">'+tr+'</tr>');
        $('.news_str').children('td').each(function() {
            $(this).children('input, select').val('');
        });
        $('.news_str').removeClass('news_str');
        reset_index();
    });

    $(document).on('click', '.remove_field', function() {
        var c = $(this).closest('tbody').children('tr').length;
        if (c>1) $(this).closest('tr').remove();
    });

    $(document).on('click', '.remove_tab', function() {
        $(this).closest('.tab-setting').remove();
        reset_index();
    });

    $('.sort-str').sortable({
      stop: function(event, ui) {reset_index();}
    });

    $('.tab-settings').sortable({
      stop: function(event, ui) {reset_index();}
    });


    function reset_index() {
        var ind = 10;

        $('.tab-setting').each(function() {
            $setting = $(this);
            var name = 'struct[tabs][' + rowsPrefix + 'tab' + ind + ']';

            $.each(['caption', 'introtext'], function() {
                $setting.find('.' + this).attr('name', name + '[' + this + ']');
            });

            name += '[settings]';

            var sn = 0,
                match;
            
            $setting.find('tbody tr').each(function() {
                $(this).find('input, select').each(function() {
                    if (match = this.name.match(/(\[[^\[\]]+\])$/)) {
                        $(this).attr('name', name + '[' + sn + ']' + match[1]);
                    }
                });
                
                sn++;
            });

            ind += 10;
        });
    }
})(jQuery);
