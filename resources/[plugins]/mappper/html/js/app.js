(function(){

	window.MAPPER = {
		currentTool                : null,
    currentObjectSelectorOption: 0,
    objectTree                 : null,
    currentNodeToRename        : null,
    currentFileName            : 'default',
	}

	MAPPER.SelectTool = function(tool){
		
		MAPPER.currentTool = tool;

		$('.tool').removeClass('selected');
		$('.tool[data-tool="' + tool + '"]').addClass('selected');
		$('#toolbox-right .toolbox').hide();
		$('.toolbox[data-tool="' + tool + '"]').show();

    if(tool == 'camera'){
      $('#wrapper').hide();
    }

    if(tool == 'edit'){

      $('#wrapper').hide();

      $('#crosshair').show();

      $.post('http://mappper/editor.get_object_infos', '{}').success(function(data){

        if(data == false) {
          $('input[name="position-x"]').val('');
          $('input[name="position-y"]').val('');
          $('input[name="position-z"]').val('');
          $('input[name="rotation-x"]').val('');
          $('input[name="rotation-y"]').val('');
          $('input[name="rotation-z"]').val('');
        } else {
          $('input[name="position-x"]').val(data.pos.x);
          $('input[name="position-y"]').val(data.pos.y);
          $('input[name="position-z"]').val(data.pos.z);
          $('input[name="rotation-x"]').val(data.rot.x);
          $('input[name="rotation-y"]').val(data.rot.y);
          $('input[name="rotation-z"]').val(data.rot.z);
        }

      });

    } else {
      $('#crosshair').hide();
    }

    if(tool == 'object'){
      $('#wrapper').css('display', 'flex');
    }

    if(tool == 'list'){

      $('#wrapper').css('display', 'flex');

      $('.object-tree-container').fancytree('getTree').reload({
        type: 'POST',
        url: 'http://mappper/editor.get_nodes',
        data: '{}'
      });

    }
	}

	$('.tool[data-tool]').click(function(){
    $.post('http://mappper/editor.select_tool', JSON.stringify({
      tool: $(this).data('tool')
    }));
	});

  $('.action[data-action]').click(function(){

    let action = $(this).data('action');

    switch(action){

      case 'open' : {

        $('#open-dialog').show();

        setTimeout(function(){
          
          $('#open-dialog input[name="name"]')
            .val(MAPPER.currentFileName)
            .focus()
          ;

        }, 0);

        break;
      }

      case 'save' : {

        $('#save-dialog').show();

        setTimeout(function(){
          
          $('#save-dialog input[name="name"]')
            .val(MAPPER.currentFileName)
            .focus()
          ;

        }, 0);

        break;

      }

      case 'new' : {

        $('#new-dialog').show();

        setTimeout(function(){
          
          $('#new-dialog input[name="name"]')
            .val('new_file')
            .focus()
          ;

        }, 0);

        break;
      }

    }

  });

	$('.toolbox[data-tool="object"] input[name="object-name"]')
    .change(function(){

      MAPPER.currentObjectSelectorOption = 0;

      $.ajax({
        method: 'POST',
        url: "http://mappper/editor.get_objects",
        dataType: 'json',
        data: JSON.stringify({
          q: $(this).val()
        }),
        success: function(data) {

          let select = $('select[name="object-list"]')[0];

          select.innerHTML = '';

          for(let i=0; i<data.length; i++){
            let option = document.createElement('option');
            option.value     = data[i].name;
            option.innerHTML = data[i].name;
            select.appendChild(option);
          }

          $('select[name="object-list"]')
            .trigger('chosen:updated')
            .change()
          ;
        }
      });

    })
    .on('keyup', function(event){

      if(event.which == 38){
        
        MAPPER.currentObjectSelectorOption = (MAPPER.currentObjectSelectorOption > 0 ? MAPPER.currentObjectSelectorOption - 1 : 0);
        
        $('select[name="object-list"]').find('option[selected]').removeAttr('selected');
        $('select[name="object-list"]').find('option')[MAPPER.currentObjectSelectorOption].selected = 'selected';
        $('select[name="object-list"]').change();

        return;
      }

      if(event.which == 40){

        MAPPER.currentObjectSelectorOption = (MAPPER.currentObjectSelectorOption < $('select[name="object-list"]').find('option').length ? MAPPER.currentObjectSelectorOption + 1 : $('select[name="object-list"]').find('option').length - 1);
        
        $('select[name="object-list"]').find('option[selected]').removeAttr('selected');
        $('select[name="object-list"]').find('option')[MAPPER.currentObjectSelectorOption].selected = 'selected';
        $('select[name="object-list"]').change();

        return;
      }

      MAPPER.currentObjectSelectorOption = 0;

      $.ajax({
        method: 'POST',
        url: "http://mappper/editor.get_objects",
        dataType: 'json',
        data: JSON.stringify({
          q: $(this).val()
        }),
        success: function(rawData) {
          
          let data = JSON.parse(rawData);

          let select = $('select[name="object-list"]')[0];

          select.innerHTML = '';

          for(let i=0; i<data.length; i++){
            let option = document.createElement('option');
            option.value     = data[i].name;
            option.innerHTML = data[i].name;
            select.appendChild(option);
          }

          if(event.which != 13)
            $(select).change();
        }
      });

    })
  ;

  $('select[name="object-list"]')
    .chosen({
      width: '100%',
      disable_search: true,
      max_selected_options: 1,
    })
    .on('chosen:showing_dropdown', function(){
      $(this).trigger('activate')
    })
    .change(function(){
      
      $.post('http://mappper/editor.tool.object.select', JSON.stringify({
        name   : $(this).val(),
        dynamic: $('input[name="object-dynamic"]').is(':checked'),
        frozen : $('input[name="object-freeze"]').is(':checked')
      }));

      $('select[name="object-list"] option').each(function(i, e){
      	if(e.selected)
      		MAPPER.currentObjectSelectorOption = i;
      });

      setTimeout(function(){
      	$(document.body).focus();
      }, 0);

    })

  $('input[name^="position-"]').spinner({
    step: 0.001
  })

  $('input[name^="rotation-"]').spinner({
    step: 0.5,
    min : 0,
    max : 360
  })

  $('input[name="position-x"]')
    .on('spin', function(event, ui){
      $.post('http://mappper/editor.set_object_position', JSON.stringify({
        x: parseFloat(ui.value),
        y: parseFloat($('input[name="position-y"]').val()),
        z: parseFloat($('input[name="position-z"]').val()),
      }))
    })
  ;

  $('input[name="position-y"]')
    .on('spin', function(event, ui){
      $.post('http://mappper/editor.set_object_position', JSON.stringify({
        x: parseFloat($('input[name="position-x"]').val()),
        y: parseFloat(ui.value),
        z: parseFloat($('input[name="position-z"]').val()),
      }))
    })
  ;

  $('input[name="position-z"]')
    .on('spin', function(event, ui){
      $.post('http://mappper/editor.set_object_position', JSON.stringify({
        x: parseFloat($('input[name="position-x"]').val()),
        y: parseFloat($('input[name="position-y"]').val()),
        z: parseFloat(ui.value),
      }))
    })
  ;

  $('input[name="rotation-x"]')
    .on('spin', function(event, ui){
      $.post('http://mappper/editor.set_object_rotation', JSON.stringify({
        x: parseFloat(ui.value),
        y: parseFloat($('input[name="rotation-y"]').val()),
        z: parseFloat($('input[name="rotation-z"]').val()),
      }))
    })
  ;

  $('input[name="rotation-y"]')
    .on('spin', function(event, ui){
      $.post('http://mappper/editor.set_object_rotation', JSON.stringify({
        x: parseFloat($('input[name="rotation-x"]').val()),
        y: parseFloat(ui.value),
        z: parseFloat($('input[name="rotation-z"]').val()),
      }))
    })
  ;

  $('input[name="rotation-z"]')
    .on('spin', function(event, ui){
      $.post('http://mappper/editor.set_object_rotation', JSON.stringify({
        x: parseFloat($('input[name="rotation-x"]').val()),
        y: parseFloat($('input[name="rotation-y"]').val()),
        z: parseFloat(ui.value),
      }))
    })
  ;


  $('input[name^="position-"]')
    .change(function(){
      $.post('http://mappper/editor.set_object_position', JSON.stringify({
        x: parseFloat($('input[name="position-x"]').val()),
        y: parseFloat($('input[name="position-y"]').val()),
        z: parseFloat($('input[name="position-z"]').val()),
      }))
    })
  ;

  $('input[name^="rotation-"]')
    .change(function(){

      let val = parseFloat($(this).val());

      $.post('http://mappper/editor.set_object_rotation', JSON.stringify({
        x: parseFloat($('input[name="rotation-x"]').val()),
        y: parseFloat($('input[name="rotation-y"]').val()),
        z: parseFloat($('input[name="rotation-z"]').val()),
      }))

      if(val >= 360)
        $(this).val(0);

    })
  ;


  $('input[name="object-freeze"]').change(function(){
    
    let checked = this.checked;

    $.post('http://mappper/editor.set_object.freeze', JSON.stringify({
      freeze: checked
    }));

    $('input[name="object-freeze"]').each(function(){
      this.checked = checked
    })
  })

  $('input[name="object-dynamic"]').change(function(){

    let checked = this.checked;

    $.post('http://mappper/editor.set_object.dynamic', JSON.stringify({
      dynamic: checked
    }));

    $('input[name="object-dynamic"]').each(function(){
      this.checked = checked
    })

  })

  $('.object-tree-container').fancytree({
    extensions: ['contextMenu'],
    source: $.ajax({
      type: 'POST',
      url: 'http://mappper/editor.get_nodes',
      data: '{}'
    }),
    contextMenu: {
      menu: {
        select: {name: 'Select'},
        rename: {name: 'Rename'},
        delete: {name: 'Delete'},
      },
      actions: function(node, action, options) {
        
        switch(action) {

          case 'select' : {
            $.post('http://mappper/editor.select_node', JSON.stringify({
              id : parseInt(node.key)
            }))
            break;
          }

          case 'rename' : {
            MAPPER.currentNodeToRename = node;
            
            $('#rename-dialog').show();
            
            setTimeout(function(){
              $('#rename-dialog input[name="name"]').focus();
            }, 0);

            break;
          }

          case 'delete' : {
            $.post('http://mappper/editor.delete_node', JSON.stringify({
              id : parseInt(node.key)
            })).success(function(data){
              $('.object-tree-container').fancytree('getTree').reload({
                type: 'POST',
                url: 'http://mappper/editor.get_nodes',
                data: '{}'
              });
            })
            break;
          }


        }

      }
    },
  });

  $('#rename-dialog input[name="name"]').keyup(function(event){
    if(event.which == 13){
      
      MAPPER.currentNodeToRename.setTitle('[' + MAPPER.currentNodeToRename.key + ']' + $(this).val());

      $.post('http://mappper/editor.rename_node', JSON.stringify({
        id  : parseInt(MAPPER.currentNodeToRename.key),
        name: $(this).val()
      }));

      $('#rename-dialog input[name="name"]').val('');
      $('#rename-dialog').hide();
    }
  });

  $('#open-dialog input[name="name"]').keyup(function(event){
    if(event.which == 13){
      
      let file               = $(this).val();
      MAPPER.currentFileName = file;

      $.post('http://mappper/editor.action', JSON.stringify({
        action: 'open',
        file  : file
      }));

      $('#open-dialog').hide();

      $('.object-tree-container').fancytree('getTree').reload({
        type: 'POST',
        url: 'http://mappper/editor.get_nodes',
        data: '{}'
      });

    }
  });

  $('#save-dialog input[name="name"]').keyup(function(event){
    if(event.which == 13){
      
      let file               = $(this).val();
      MAPPER.currentFileName = file;

      $.post('http://mappper/editor.action', JSON.stringify({
        action: 'save',
        file  : file
      }));

      $('#save-dialog').hide();

    }
  });

  $('#new-dialog input[name="name"]').keyup(function(event){
    if(event.which == 13){
      
      let file               = $(this).val();
      MAPPER.currentFileName = file;

      $.post('http://mappper/editor.action', JSON.stringify({
        action: 'new',
        file  : file
      }));

      $('#new-dialog').hide();

      $('.object-tree-container').fancytree('getTree').reload({
        type: 'POST',
        url: 'http://mappper/editor.get_nodes',
        data: '{}'
      });

    }
  });


  $('#crosshair').hide();

	window.onData = (data) => {

		switch(data.action){

			case 'editor.hide_menu' : {
				$('#wrapper').hide();
				break;
			}

			case 'editor.show_menu' : {

        $.post('http://mappper/editor.get_object_infos', '{}').success(function(data){

          if(data == false) {
            $('input[name="position-x"]').val('');
            $('input[name="position-y"]').val('');
            $('input[name="position-z"]').val('');
            $('input[name="rotation-x"]').val('');
            $('input[name="rotation-y"]').val('');
            $('input[name="rotation-z"]').val('');
          } else {
            $('input[name="position-x"]').val(data.pos.x);
            $('input[name="position-y"]').val(data.pos.y);
            $('input[name="position-z"]').val(data.pos.z);
            $('input[name="rotation-x"]').val(data.rot.x);
            $('input[name="rotation-y"]').val(data.rot.y);
            $('input[name="rotation-z"]').val(data.rot.z);
          }

        });

				$('#wrapper').css('display', 'flex');

				break;
			}

			case 'editor.select_tool' : {
				MAPPER.SelectTool(data.tool)
				break;
			}

      case 'editor.set_crosshair' : {
        if(data.enabled)
          $('#crosshair').show();
        else
          $('#crosshair').hide();
      }

      case 'editor.object_infos' : {

        if(data.infos) {
          $('input[name="position-x"]').val(data.infos.pos.x);
          $('input[name="position-y"]').val(data.infos.pos.y);
          $('input[name="position-z"]').val(data.infos.pos.z);
          $('input[name="rotation-x"]').val(data.infos.rot.x);
          $('input[name="rotation-y"]').val(data.infos.rot.y);
          $('input[name="rotation-z"]').val(data.infos.rot.z);
        } else {
          $('input[name="position-x"]').val('');
          $('input[name="position-y"]').val('');
          $('input[name="position-z"]').val('');
          $('input[name="rotation-x"]').val('');
          $('input[name="rotation-y"]').val('');
          $('input[name="rotation-z"]').val('');
        }

      }

		}

	}

	window.onload = function(e){

		window.addEventListener('message', (event) => {
			onData(event.data)
		});
	};

  document.onkeyup = function(event) {
    
    if(event.which == 27 || (event.which == 82 && $(':focus').length == 0) ) {
      $.post('http://mappper/editor.hide_menu', '{}');
      $('.input-dialog').hide();
    }

    if(event.which == 49 && $(':focus').length == 0){
      $.post('http://mappper/editor.select_tool', JSON.stringify({
        tool: 'camera'
      }));
    }

    if(event.which == 50 && $(':focus').length == 0){
      $.post('http://mappper/editor.select_tool', JSON.stringify({
        tool: 'edit'
      }));
    }

    if(event.which == 51 && $(':focus').length == 0){
      $.post('http://mappper/editor.select_tool', JSON.stringify({
        tool: 'object'
      }));
    }

    if(event.which == 52 && $(':focus').length == 0){
      $.post('http://mappper/editor.select_tool', JSON.stringify({
        tool: 'list'
      }));
    }

    if(MAPPER.currentTool == 'object'){

      if(event.which == 13) {
        $.post('http://mappper/editor.select_tool', JSON.stringify({
          tool: 'edit'
        }));
      }

      if(event.which == 38) {
       
        MAPPER.currentObjectSelectorOption = (MAPPER.currentObjectSelectorOption > 0 ? MAPPER.currentObjectSelectorOption - 1 : 0);
        
        $('select[name="object-list"]').find('option[selected]').removeAttr('selected');
        $('select[name="object-list"]').find('option')[MAPPER.currentObjectSelectorOption].selected = 'selected';
        
        $('select[name="object-list"]')
          .trigger('chosen:updated')
          .change()
        ;
      }

      if(event.which == 40) {

        MAPPER.currentObjectSelectorOption = (MAPPER.currentObjectSelectorOption < $('select[name="object-list"]').find('option').length ? MAPPER.currentObjectSelectorOption + 1 : $('select[name="object-list"]').find('option').length - 1);
        
        $('select[name="object-list"]').find('option[selected]').removeAttr('selected');
        $('select[name="object-list"]').find('option')[MAPPER.currentObjectSelectorOption].selected = 'selected';
        
        $('select[name="object-list"]')
          .trigger('chosen:updated')
          .change()
        ;
      }

    }

  };

})();