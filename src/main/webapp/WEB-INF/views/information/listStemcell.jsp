<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script type="text/javascript" src="<c:url value='/js/sockjs-0.3.4.js'/>"></script>
<script type="text/javascript" src="<c:url value='/js/stomp.js'/>"></script>

<script type="text/javascript">
var uploadClient = null;
var deleteClient = null;

$(function() {
	
 	// 기본 설치 관리자 정보 조회
 	var bDefaultDirector = getDefaultDirector("<c:url value='/directors/default'/>");
 	
 	$('#us_uploadStemcellsGrid').w2grid({
		name	: 'us_uploadStemcellsGrid',
		show: {selectColumn: true, footer: true},
		multiSelect: false,
		method: 'GET',
		style: 'text-align:center',
		columns	:[
		           {field: 'recid', caption: 'recid', hidden: true}
		         , {field: 'operatingSystem', caption: '운영체계', size: '30%'}
		         , {field: 'name', caption: '스템셀명', size: '40%'}		         
		         , {field: 'version', caption: '스템셀버전', size: '30%'}
/* 		         , {field: 'deploymentInfo', caption: '배포명', size: '20%',
		        	 	render: function(record) {
		 	    		   if ( record.deploymentInfo != '' )
			    			   return '<span class="btn btn-success" style="width:70px">' + record.deploymentInfo + '</span>';
			    		   else
			    			   return '';
		        	 	}
		        	 } */
		         ],
 		onSelect: function(event) {
			event.onComplete = function() { 				
				setDisable($('#doDeleteStemcell'), false);
			}
		},
		onUnselect: function(event) {
			event.onComplete = function() {
				setDisable($('#doDeleteStemcell'), true);
			}
		},
		onError: function(event) {
			this.unlock();
			gridErrorMsg(event);
		}
	});
	
 	$('#us_localStemcellsGrid').w2grid({
		name: 'us_localStemcellsGrid',
		header: '<b>Local Stemcell 목록</b>',
		show: {selectColumn: true, footer: true},
		multiSelect: false,
		method: 'GET',
		style: 'text-align:center',
		columns:[
			 {field: 'recid', caption: '운영체계', hidden: true}
			,{field: 'os', caption: '운영체계', size: '10%'}
			,{field: 'osVersion', caption: '버전', size: '10%'}
			,{field: 'iaas', caption: 'IaaS', size: '10%', sortable: true}
			,{field: 'stemcellVersion', caption: '스템셀버전', size: '10%'}
			,{field: 'stemcellFileName', caption: '파일명', size: '60%', style: 'text-align:left'}
		],
		onSelect: function(event) {
			event.onComplete = function() {
				if ( bDefaultDirector ) {
					setDisable($('#doUploadStemcell'), false);
				}
			}
		},
		onUnselect: function(event) {
			event.onComplete = function() {
				setDisable($('#doUploadStemcell'), true);
			}
		},
		onError: function(event) {
			event.preventDefault();
			this.unlock();
		}
	});
 	
 	initView(bDefaultDirector);
 	
 	// 스템셀 삭제
 	$("#doDeleteStemcell").click(function(){
 		if($("#doDeleteStemcell").attr('disabled') == "disabled") return;
 		doDeleteStemcell();
    });
 	
 	// 스템셀 업로드
 	$("#doUploadStemcell").click(function(){
 		if($("#doUploadStemcell").attr('disabled') == "disabled") return;
 		doUploadStemcell();
    });

});


function initView(bDefaultDirector) {
	// 업로드된 스템셀 조회
	if ( bDefaultDirector ) {
	 	doSearchUploadedStemcells();
	}
	
	// 로컬에 다운로드된 스템셀 조회
	doSearchLocalStemcells();

	// 컨트롤 
	setDisable($('#doDeleteStemcell'), true);
	setDisable($('#doUploadStemcell'), true);
}

function setDisable(object, flag) {
	object.attr('disabled', flag);
}

//업로드된 스템셀 조회
function doSearchUploadedStemcells() {
	w2ui['us_uploadStemcellsGrid'].load("<c:url value='/stemcells'/>");
}

//로컬에 다운로드된 스템셀 조회
function doSearchLocalStemcells() {
	w2ui['us_localStemcellsGrid'].load("<c:url value='/localStemcells'/>", "");
}

//다른페이지 이동시 호출
function clearMainPage() {
	$().w2destroy('us_uploadStemcellsGrid');
	$().w2destroy('us_localStemcellsGrid');
}

// 스템셀 삭제
function doDeleteStemcell() {
	var selected = w2ui['us_uploadStemcellsGrid'].getSelection();
	if ( selected == "" || selected == null) return;
	
	var record = w2ui['us_uploadStemcellsGrid'].get(selected);
	if ( record == "" || record == null) return;

	var requestParameter = {
			stemcellName : record.name,
			version  : record.version
		};
	
	w2confirm( { msg : record.version + '버전의 스템셀 <br>' + record.name + '<br>을 삭제하시겠습니까?'
		, title : '스템셀 삭제'
		, yes_text:'확인'
		, no_text:'취소'
		, yes_callBack : function (){
				deleteLogPopup(requestParameter);	
			}
	});	
}

//스템셀 업로드
function doUploadStemcell() {
	var selected = w2ui['us_localStemcellsGrid'].getSelection();
	if ( selected == "" || selected == null) return;
	
	var record = w2ui['us_localStemcellsGrid'].get(selected);
	if ( record == "" || record == null) return;
	
	var requestParameter = {
			fileName : record.stemcellFileName,
			version: record.stemcellVersion
		};
	
	w2confirm( { msg : '스템셀  <br>' + record.stemcellFileName + '을(를)<br> 설치관리자에 업로드하시겠습니까?'
		, title : '스템셀 업로드'
		, yes_text:'확인'
		, no_text:'취소'
		, yes_callBack : function (){
			uploadLogPopup(requestParameter);
			}
	});
}

//Log Popup Create
function uploadLogPopup(requestParameter){
	var uploadLogPopupBody = '<br/><textarea name="logAppendArea" readonly="readonly" style="width:100%;height:85%;overflow-y:visible ;resize:none;background-color: #FFF;"></textarea>';
	var uploadLogPopupButton = '<button id="closeBtn" class="btn closeBtn" onclick="popupClose(); disabled">확인</button>'
	var progressLayer = '<div class="progress" style="height:6%;margin:10px 0 0 0;">';
	progressLayer += '<div class="progress-bar progress-bar-striped active" role="progressbar" ';
	progressLayer += 'aria-valuemin="0" aria-valuemax="100" style=";padding-top:0.5%;font-size:13px;"></div></div>';
	
	w2popup.open({
		title	: '<b>스템셀 업로드</b>',
		body	: progressLayer + uploadLogPopupBody,
		buttons : uploadLogPopupButton,
		width 	: 800,
		height	: 550,
		modal	: true,
		showMax : true,
		onOpen  : function(){
			doUploadConnect(requestParameter);
		}
	});
}

//Log Popup Create
function deleteLogPopup(requestParameter){
	var deleteLogPopupBody = '<br/><textarea name="logAppendArea" readonly="readonly" style="width:100%;height:95%;overflow-y:visible ;resize:none;background-color: #FFF;"></textarea>';
	var deleteLogPopupButton = '<button id="closeBtn" class="btn closeBtn" onclick="popupClose(); disabled">확인</button>';
	
	w2popup.open({
		title	: '<b>스템셀 삭제</b>',
		body	: deleteLogPopupBody,
		buttons : deleteLogPopupButton,
		width 	: 800,
		height	: 550,
		modal	: true,
		showMax : true,
		onOpen  : function(){
			doDeleteConnect(requestParameter);
		}
	});
}

//Stemcell Upload connect
function doUploadConnect(requestParameter){
	
	var message = requestParameter.version + " 버전의 스템셀(" + requestParameter.fileName + ") ";
	
	var socket = new SockJS('/stemcellUploading');
	uploadClient = Stomp.over(socket); 
	uploadClient.connect({}, function(frame) {
        console.log('Connected: ' + frame);
        uploadClient.subscribe('/socket/uploadStemcell', function(data){

        	var response = JSON.parse(data.body);
        	console.log("##### : "+ requestParameter.fileName + " : " + response.tag +" = " +(requestParameter.fileName == response.tag) );
	        if(requestParameter.fileName == response.tag){
	        	if ( response.messages != null ) {
	        		if(  response.state.toLowerCase() != "progress" ) {
				       	for ( var i=0; i < response.messages.length; i++) {
				       		$("textarea[name='logAppendArea']").append(response.messages[i] + "\n").scrollTop($("textarea[name='logAppendArea']")[0].scrollHeight);
				       	}
				       	
				       	if ( response.state.toLowerCase() != "started" ) {
				            if ( response.state.toLowerCase() == "done" )	message = message + " 업로드 되었습니다."; 
				    		if ( response.state.toLowerCase() == "error" ) message = message + " 업로드 중 오류가 발생하였습니다.";
				    		if ( response.state.toLowerCase() == "cancelled" ) message = message + " 업로드 중 취소되었습니다.";
				    			
				    		uploadClient.disconnect();
							w2alert(message, "스템셀 업로드");
				       	}
	        		}
	        		else { 
			       		//progressbar
			       		console.log("#### :" + data);
			       		if( response.messages < 100){
			       			$(".w2ui-box1 .progress-bar").css("width", response.messages+"%").text("Uploading "+response.messages+"% ");
			       		}
			       		else if( response.messages = 100){
			       			$(".w2ui-box1 .progress-bar").css("width", "100%").text("Uploaded");
			       		}
			       	}
	        	}
	        }
        });
        socketSendUploadData( requestParameter);
    });
}

//Stemcell Delete connect
function doDeleteConnect(requestParameter){
	
	var message = requestParameter.version + " 버전의 스템셀(" + requestParameter.stemcellName + ") ";
	
	var socket = new SockJS('/stemcellDelete');
	deleteClient = Stomp.over(socket); 
	deleteClient.connect({}, function(frame) {
        deleteClient.subscribe('/socket/deleteStemcell', function(data){
	        var response = JSON.parse(data.body);
	        
	        if ( response.messages != null ) {
		       	for ( var i=0; i < response.messages.length; i++) {
		       		$("textarea[name='logAppendArea']").append(response.messages[i] + "\n").scrollTop($("textarea[name='logAppendArea']")[0].scrollHeight);
		       	}
		       	
		       	if ( response.state.toLowerCase() != "started" ) {
		            if ( response.state.toLowerCase() == "done" )	message = message + " 삭제되었습니다."; 
		    		if ( response.state.toLowerCase() == "error" ) message = message + " 삭제 중 오류가 발생하였습니다.";
		    		if ( response.state.toLowerCase() == "cancelled" ) message = message + " 삭제 중 취소되었습니다.";
		    			
		            deleteClient.disconnect();
					w2alert(message, "스템셀 삭제");
		       	}
	        }
        });
        socketSendDeleteData(requestParameter);
    });
}

//socket으로 데이터 전송
function socketSendUploadData(requestParameter){
	uploadClient.send('/app/stemcellUploading', {}, JSON.stringify(requestParameter));
}

function socketSendDeleteData(requestParameter){
	deleteClient.send('/app/stemcellDelete', {}, JSON.stringify(requestParameter));
}

//팝업 닫을 경우 Socket Connection 종료 및 log 영역 초기화
function popupClose() {
	if (uploadClient != null) {
		uploadClient.disconnect();
		$("textarea[name='logAppendArea']").text("");
	}
	
	if (deleteClient != null) {
		deleteClient.disconnect();
		$("textarea[name='logAppendArea']").text("");
	}
	
	w2popup.close();
	
	// 업로드된 스템셀 조회
 	doSearchUploadedStemcells();
 	setDisable($('#doUploadStemcell'), true);
	
}

//화면 리사이즈시 호출
$( window ).resize(function() {
	setLayoutContainerHeight();
});
</script>

<div id="main">
	<div class="page_site">정보조회 > <strong>스템셀 업로드</strong></div>
	
	<!-- 설치 관리자 -->
	<div id="isDefaultDirector"></div>
	
	<!-- 업로드된 스템셀 목록-->
	<div class="pdt20">
		<div class="title fl">업로드된 스템셀 목록</div>
		<div class="fr"> 
			<span class="btn btn-danger" style="width:120px" id="doDeleteStemcell">스템셀 삭제</span>
	    </div>
	</div>
	<div id="us_uploadStemcellsGrid" style="width:100%; height:200px"></div>
	
	<!-- 로컬 스템셀 목록-->
	<div class="pdt20">
		<div class="title fl">다운로드된 스템셀 목록</div>
		<div class="fr"> 
			<span class="btn btn-primary" style="width:120px" id="doUploadStemcell">스템셀 업로드</span>
	    </div>
	</div>
		
	<div id="us_localStemcellsGrid" style="width:100%; height:200px"></div>
</div>
