// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


/**
 * Common
 * Back to Top
 */

$(function () {

  $('#back-to-top').hide();

  $(window).scroll(function () {
    if ($(this).scrollTop() > 60) {
      $('#back-to-top').fadeIn();
    } else {
      $('#back-to-top').fadeOut();
    }
  });

  $('#back-to-top a').click(function () {
    $('body').animate({
      scrollTop:0
    }, 500);
    return false;
  });
});


/**
 * Common
 * Loading (Not All)
 */


// Loading 画像を表示するメソッド
function _dispLoading(msg){
  $('.set_loading').fadeOut('fast', function () {
    $('.set_loading').addClass('loading').fadeIn('fast');
  });
}
 
// Loading 画像を削除するメソッド
function _removeLoading(){
  // $("#loading").remove();
  $('.set_loading').fadeOut('fast', function () {
    $('.set_loading').removeClass('loading').fadeIn('fast');
  });
}



/**
 * menu
 */

/**
 * header menu open / close
 */
$(function () {
  $(document).click(function() {
    if (!($('.header_menu_list').hasClass('display_none'))) {
      $('.header_menu_list').fadeOut('fast').addClass('display_none');
    }
  });

  $('.header_btn').on('click', function () {
    event.stopPropagation();
    if ($('.header_menu_list').hasClass('display_none')) {
      $('.header_menu_list').fadeOut('fast').fadeIn('fast').removeClass('display_none');
    } else {
      $('.header_menu_list').fadeOut('fast').addClass('display_none');
    }
  });

});

/**
 * header submenu open / close
 */
$(function () {
  $('.has_header_submenu').on('click', function () {
    event.stopPropagation();
    if ($(this).parent().next().hasClass('display_none')) {
      $(this).parent().next().fadeIn('fast').removeClass('display_none');
    } else {
      $(this).parent().next().fadeOut('fast').addClass('display_none');
    }

  });
});



/**
 * global navigation open / close
 */

$(function () {

  // ページ読込時に Global Menu が閉じていた場合は Submenu を閉じる
  if ($.cookie('global_navi_close')) {
    $('.global-navigation-submenu').addClass('submenu-is-close');
  }

  $('.menu-button').click(function () {
    _switchGlobalNavigateion();
  });
});

function _switchGlobalNavigateion()
{
  if (_isGlobalNavigationClose() === true) {
    $.removeCookie("global_navi_close");
    $('body').toggleClass('global-navigation-is-close');

    // サブメニューアイコンを遅れて表示させる
    $('.has-submenu-icon i').css('color', 'rgba(0,0,0,.0');
    setTimeout( function () {
      $('.has-submenu-icon i').css('color', ''); 
    } ,300);

  } else {
    if (!($.cookie('global_navi_close'))) {
      $.cookie("global_navi_close", "yes");
    }
    $('body').toggleClass('global-navigation-is-close');
    $('.global-navigation-submenu').addClass('submenu-is-close');
  }
}

function _isGlobalNavigationClose()
{
  if ($('body').hasClass('global-navigation-is-close')) {
    return true;
  }
  return false;
}


/**
 * menu open
 * submenu open / close
*/
$(function () {
  $('.has-submenu').click(function () {
    if (_isGlobalNavigationClose() === true) {

    } else {
      $('+ .global-navigation-submenu',this).toggleClass('submenu-is-close');
    }
  });
});




/**
 * home
 * ajax graph updater - Manual
*/
$(function () {
  $('.resource_info .ajax_update_button').on('click', function (event) {
    _getHomeAjax();
  });
});

function _getHomeAjax()
{
    $('.resource_info .ajax_update_button').addClass('pointer-events_none');
    _dispLoading();
    $.ajax({
      type: 'GET',
      url: '/home.json',
      dataType: 'JSON',
      success: function (datas) {
        // console.log(datas);

        $.each(datas, function(i, value) {
          if (i < 3) {
            i += 1;
            var number = 'chart-' + i;
            new Chartkick.PieChart(number, value);
          } else {
            var numArray = i;
            switch(numArray){
              case 3 : var val_class = '.cpu_idle'; break;
              case 4 : var val_class = '.mem_size'; break;
              case 5 : var val_class = '.mem_free'; break;
              case 6 : var val_class = '.swap_size'; break;
              case 7 : var val_class = '.swap_free'; break;
              case 8 : var val_class = '.disk_size'; break;
              case 9 : var val_class = '.disk_free'; break;
            }
            var getClass = '.resource_ul .description' + val_class;
            $(val_class).text(value);
          }
        });
      },
      complete: function () {
        _removeLoading();
        $('.resource_info .ajax_update_button').removeClass('pointer-events_none');

      }
    });
}


/**
 * home
 * ajax graph updater - Auto
*/

$(function () {
  $('#home_start').on('click', function () {

    // start ボタンを変更
    $('#home_start').text('Runnig...').addClass('button_running').addClass('pointer-events_none');
    _homeCountdownAjax();
  });
});


// カウントダウン用のグローバル変数
var gb_home_count = '';

function _homeCountdownAjax() {

  // カウントダウンの周期
  // var set_time = 30;
  var set_time = $('#home_interval').val();

  // カウントダウンの数値により処理
  if (gb_home_count === '') {
      
    // カウントダウンの数値が空白の場合は周期を代入
    gb_home_count = set_time;

  } else if (gb_home_count === 1) {

    // カウントダウンの数値が "1" になったら情報更新処理を実行し、周期を空白（初期値）に戻す

    // リソース状況の更新処理
    _getHomeAjax();

    gb_home_count = '';
   
  } else {

    // カウントダウンの数値が上記以外の場合は 1 減らす
    gb_home_count = gb_home_count - 1;
  }

  $('#home_countdown').text(gb_home_count);

  var tid = setTimeout(function() {
    _homeCountdownAjax();
  }, 1000);

  // 自動更新を停止する処理を実行
  $('#home_stop').click(function () {
    $('#home_start').text('Start').removeClass('button_running').removeClass('pointer-events_none');
    clearTimeout(tid);
  });


  // プルダウンで更新間隔が変更された場合の処理
  $('#home_interval').on('change', function () {
    console.log('step1.');
    // start ボタンを変更
    $('#home_start').text('Start').removeClass('button_running').removeClass('pointer-events_none');
    clearTimeout(tid);
    gb_home_count = '';
    $('#home_countdown').text(gb_home_count);
  });

}


/**
 * Configuration
 * textbox edit open / close
 */

$(function () {
  $('.configure_edit').click(function () {
    $(this).next('span').next('input').toggle('fast');
    $(this).next('span').next('input').toggleClass('update_field_is_close');

    if ($(this).next('span').next('input').hasClass('update_field_is_close') === true) {
      $(this).next('span').next('input').attr("disabled", "disabled");
      $(this).css({
        'background-color': '#00c0ef',
        'border': '2px solid #00acd6'
      }); 
    } else {
      $(this).next('span').next('input').removeAttr("disabled");
      $(this).css({
        'background-color': 'rgba(255,140,0,.6)',
        'border': '2px solid orange'
      }); 
    }
  });
});


/**
 * Ping Script
 * ping start / stop
 */
$(function () {

  // #pingstart をクリックすると Ping 処理を実行
  $('#pingstart').on('click', function (event) {

    // start ボタンを変更
    $('#pingstart').text('Runnig...').addClass('button_running').addClass('pointer-events_none');

    // 実行結果を表示
    $('#ping_result_div').fadeIn('slow');
    
    // Ping 停止用のフラグ（Cookie）を作成
    $.cookie("pingnow", "yes");

    // ホスト数に応じた間隔で pingnow cookie をチェックし、Cookie があれば Ping の実行と結果を取得する
    var intervalId;
    var ping_interval = $('#ping_host_length').text();

    if (ping_interval < 1000 ) {
      alert('実行周期に異常があります。確認ください。')
    }

    intervalId = setInterval(function() {
      if ($.cookie('pingnow')) {

        if (!($.cookie('ping_processing'))) {
          $.cookie("ping_processing", "yes");
          _postPingAjax()
        };
      _getPingAjax();
      };
    }, ping_interval);

    // Ping を停止する処理を実行
    $('#pingstop').click(function () {
      $.removeCookie("pingnow");
      $.removeCookie("ping_processing");
      clearInterval(intervalId);
      $('#stopbotton').empty();
      $('#pingstart').text('Start').removeClass('button_running').removeClass('pointer-events_none');
    });
  });
});


function _postPingAjax()
{
  $.ajax({
    type: 'POST',
    url: '/script/ping.json',
    dataType: 'JSON',
    success: function (datas) {
    },
    complete: function (datas) {
      $.removeCookie("ping_processing");
    }
  });
}


function _getPingAjax()
{
  $.ajax({
    type: 'GET',
    url: '/script/ping.json',
    dataType: 'JSON',
    success: function (datas) {

      $.each(datas, function(i, value) {

        var hostname = '.' + value[9] + '.ping_hostname';
        var ip = '.' + value[9] + '.ping_ip';
        var status = '.' + value[9] + '.ping_status';
        var all = '.' + value[9] + '.ping_all';
        var ng = '.' + value[9] + '.ping_ng';
        var ngpercent = '.' + value[9] + '.ping_ngpercent';
        var short = '.' + value[9] + '.ping_short';
        var long = '.' + value[9] + '.ping_long';
        var average = '.' + value[9] + '.ping_average';

        $(hostname).text(value[0]);
        $(ip).text(value[1]);
        $(status).text(value[8]);
        $(all).text(value[2]);
        $(ng).text(value[3]);
        $(ngpercent).text(value[4]);
        $(short).text(value[5]);
        $(long).text(value[6]);
        $(average).text(value[7]);
      });
    },
    complete: function () {
    }
  });
}


/**
 * Ping Script
 * ping result clear
 */
$(function () {

  $('#ping_table_clear').on('click', function (event) {
    _deletePingAjax();
  });
});


function _deletePingAjax()
{
  $.ajax({
    type: 'delete',
    url: '/script/ping.json',
    dataType: 'JSON',
    success: function (datas) {
    },
    complete: function (datas) {
      _getPingAjax();   
    }
  });
}

/**
 * SNMPTRAP Script
 * Update - Manual
 */

$(function () {
  $('#snmptrap_get_ajax').on('click', function () {
    $('#snmptrap_get_ajax').addClass('pointer-events_none');
    _getSnmptrapAjax();
  });
});

function _getSnmptrapAjax()
{
  $.ajax({
    type: 'GET',
    url: '/script/snmptrap.json',
    dataType: 'JSON',
    success: function (datas) {

      if ($.isEmptyObject(datas)) {
        var results = '<tr><td class="set_loading" colspan="7">直近でSNMPトラップは検知していません。</td></tr>';
      } else {
        var results = '';
        $.each(datas, function(i, value) {
          var td = '<tr><td class="trap_month set_loading">' + value[0] + '</td><td class="trap_month set_loading">' + value[1] + '</td><td class="trap_month set_loading">' + value[2] + '</td><td class="trap_month set_loading">' + value[3] + '</td><td class="trap_month set_loading">' + value[4] + '</td><td class="trap_month set_loading">' + value[5] + '</td><td class="trap_month set_loading">' + value[6] + '</td></tr>';
          results += td;
        });
      }
      $('tbody#snmptrap_change_tbody').html(results);
    },
    complete: function () {
      _removeLoading();
      $('#snmptrap_get_ajax').removeClass('pointer-events_none');
    }
  });
}



/**
 * SNMPTRAP Script
 * Update - Auto
 */

$(function () {
  $('#snmptrap_start').on('click', function () {

    // start ボタンを変更
    $('#snmptrap_start').text('Runnig...').addClass('button_running').addClass('pointer-events_none');

    _snmptrapCountdownAjax();

  });
});


// カウントダウン用のグローバル変数
var gb_snmptrap_count = '';

function _snmptrapCountdownAjax() {

  // カウントダウンの周期
  // var set_time = 30;
  var set_time = $('#snmptrap_interval').val();

  // カウントダウンの数値により処理
  if (gb_snmptrap_count === '') {
      
    // カウントダウンの数値が空白の場合は周期を代入
    gb_snmptrap_count = set_time;

  } else if (gb_snmptrap_count === 1) {

    // カウントダウンの数値が "1" になったら情報更新処理を実行し、周期を空白（初期値）に戻す

    // SNMP TRAP 関連の処理
    _getSnmptrapAjax();

    gb_snmptrap_count = '';
   
  } else {

    // カウントダウンの数値が上記以外の場合は 1 減らす
    gb_snmptrap_count = gb_snmptrap_count - 1;
  }

  $('#snmptrap_countdown').text(gb_snmptrap_count);

  var tid = setTimeout(function() {
    _snmptrapCountdownAjax();
  }, 1000);

  // 自動更新を停止する処理を実行
  $('#snmptrap_stop').click(function () {
    $('#snmptrap_start').text('Start').removeClass('button_running').removeClass('pointer-events_none');
    clearTimeout(tid);
  });


  // プルダウンで更新間隔が変更された場合の処理
  $('#snmptrap_interval').on('change', function () {

    // start ボタンを変更
    $('#snmptrap_start').text('Start').removeClass('button_running').removeClass('pointer-events_none');
    clearTimeout(tid);
    gb_snmptrap_count = '';
    $('#snmptrap_countdown').text(gb_snmptrap_count);
  });

}

/**
 * Techsupport
 * redirect wait
 */

$(function () {
  $('#get_techsupport').click(function () {

    $(this).prop('disabled', true).text('Running...').addClass('button_running');

    window.location.href = "/maintenance/techsupport/new";

    var intervalId;

    // 1 秒間隔で exported cookie をチェック
    intervalId = setInterval(function() {
      if ($.cookie('exported')) {
        // 実行ボタンをアンロック後ラベルを元に戻す
        $('#get_techsupport').prop('disabled', false).text('Start').removeClass('button_running');

        // 処理が正常に完了した旨のメッセージを表示
        // $('#message').text('正常に終了しました。');

        // ポーリングを停止
        clearInterval(intervalId);
        // フラグをクリア
        $.removeCookie('exported', { path: '/' });
      }
    }, 1000);
  });
});


/**
 * Tool
 */

$(function () {

  // 設定情報の取得
  $('#tool_config_export').on('click', function (event) {
    if(!confirm('MonitorBoxの設定情報を取得しますか？')){
      return false;
    }else{
      _accessActionTools('config_export');
    }
  });

  // 設定情報のインポート
  $('#tool_config_import').on('click', function (event) {
      _accessActionTools('config_import');
  });


  // 各サービスの再起動
  $('#tool_restart_zbxproxy').on('click', function (event) {
    if(!confirm('Zabbix Proxyサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_zbxproxy');
    }
  });

  $('#tool_restart_zbxagent').on('click', function (event) {
    if(!confirm('Zabbix Agentサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_zbxagent');
    }
  });

  $('#tool_restart_pgsql').on('click', function (event) {
    if(!confirm('Postgresqlサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_pgsql');
    }
  });

  $('#tool_restart_snmptt').on('click', function (event) {
    if(!confirm('SNMPTTサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_snmptt');
    }
  });

  $('#tool_restart_snmptrapd').on('click', function (event) {
    if(!confirm('SNMPT TRAPDサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_snmptrapd');
    }
  });

  $('#tool_restart_ntpd').on('click', function (event) {
    if(!confirm('NTPサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_ntpd');
    }
  });

  $('#tool_restart_rsyslogd').on('click', function (event) {
    if(!confirm('NTPサービスを再起動しても問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('restart_rsyslogd');
    }
  });

  // MonitorBox の再起動
  $('#tool_mb_reboot').on('click', function (event) {
    if(!confirm('MonitorBoxの再起動を実施して問題ないですか？（サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('mb_reboot');
    }
  });

  // MIB、SNMPTT の Git 更新とサービス再起動
  $('#tool_mib_snmptt_update').on('click', function (event) {
    if(!confirm('MIB,SNMPTT Fileを最新情報に変更して問題ないですか？（SNMPTTサービスの再起動が発生しますので、サービス影響がないか再度ご確認ください。）')){
      return false;
    }else{
      _getActionTools('mib_snmptt_update');
    }
  });


});


function _accessActionTools(tool){
  window.location.href = "/tool?&key=" + tool;
}


function _getActionTools(tool){
  $('.all_loading').removeClass('is-hide');
  $.ajax({
    type: 'GET',
    url: '/tool?&key=' + tool,
    dataType: 'JSON',
    success: function (datas) {
    },
    complete: function (datas) {
      $('.all_loading').addClass('is-hide');
      alert(datas['responseText']);
    }
  });
}







