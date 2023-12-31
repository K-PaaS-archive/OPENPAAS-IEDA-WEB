<%
/* =================================================================
 * 작성일 : 
 * 작성자 : 
 * 상세설명 : 설치관리자 조회 및 설정
 * =================================================================
 * 수정일         작성자             내용     
 * ------------------------------------------------------------------
 * 2016-08       지향은      설치관리자 설정 화면 개선
 * =================================================================
 */ 
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<script type="text/javascript">

var fadeOutTime = 3000;
$(function() {
	/********************************************************
	 * 설명 :  설치관리자 목록 조회
	 *********************************************************/
  	$('#config_directorGrid').w2grid({
		name: 'config_directorGrid',
		header: '<b>설치관리자 목록</b>',
 		method: 'GET',
 		multiSelect: false,
		show: {	
				selectColumn: true,
				footer: true},
		style: 'text-align: center',
		columns:[
				 {field: 'recid', caption: 'recid', hidden: true},
		         {field: 'iedaDirectorConfigSeq', 	caption: '레코드키', 		hidden: true},
		         {field: 'defaultYn', 	caption: '기본 관리자',	size: '10%',
			    	   render: function(record) {
			    		   if ( record.defaultYn == 'Y' )
			    			   return '<span class="btn btn-primary" style="width:70px">기본</span>';
			    		   else
			    			   return '';
			    	   }
		        	 },
		         {field: 'directorCpi', 			caption: 'CPI',			size: '10%'},
		         {field: 'directorName', 			caption: '관리자 이름',		size: '10%'},
		         {field: 'userId', 					caption: '계정',			size: '10%'},
		         {field: 'directorUrl', 			caption: 'URL', 		size: '30%',
		        	 render: function(record) {
		        		 return 'https://' + record.directorUrl + ':' + record.directorPort;
		        		 } 
		         },
		         {field: 'directorUUID', caption: '관리자 UUID', size: '30%'}
		         ],
		onSelect : function(event) {
			var grid = this;
			event.onComplete = function() {
				var sel = grid.getSelection();
				var record = grid.get(sel);
				if ( record.defaultYn == 'Y' ) {
					$('#setDefaultDirector').attr('disabled', true);
				}
				else {
					$('#setDefaultDirector').attr('disabled', false);
				}
				
				$('#updateSetting').attr('disabled', false);
				$('#deleteSetting').attr('disabled', false);
			}
		},
		onUnselect : function(event) {
			event.onComplete = function() {
				$('#setDefaultDirector').attr('disabled', true);
				$('#deleteSetting').attr('disabled', true);
				$('#updateSetting').attr('disabled', true);
			}
		}, 
		onLoad:function(event){
			if(event.xhr.status == 403){
				location.href = "/abuse";
				event.preventDefault();
			}
		},
		onError: function(event) {
			
		}
	});
  	
 	initView();
 	/********************************************************
 	 * 설명 :  기본 설치 관리자 설정
 	 *********************************************************/
 	$("#setDefaultDirector").click(function(){
 		if($("#setDefaultDirector").attr('disabled') == "disabled") return;
 		
 		var selected = w2ui['config_directorGrid'].getSelection();
 		if( selected.length == 0 ){
 			w2alert("선택된 정보가 없습니다.", "기본 설치 관리자 설정");
 			return;
 		}
 		else  if ( selected.length > 1 ){
 			w2alert("기본 설치 관리자 설정은 하나만 선택 가능합니다.", "기본 설치 관리자 설정");
 			return;
 		}
 		else{
 			var record = w2ui['config_directorGrid'].get(selected);
 			if( record.defaultYn == "Y" ){
 				//클릭시 버튼  Disable 다른 페이지 호출
 				w2alert("선택한 설치 관리자는 이미 기본 설치 관리자로 설정되어 있습니다.","기본 설치 관리자 설정");
 				return;
 			}
 			else{
	 			w2confirm({
	 				title 			: "기본관리자 설정",
	 				msg 			: record.directorName + "를 " + "기본관리자로 설정하시겠습니까?",
	 				yes_text 		: "확인",
	 				no_text			: "취소",
	 				yes_callBack	: function(envent){
	 									w2ui['config_directorGrid'].lock("기본관리자 설정 중입니다.", {
	 										spinner: true, opacity : 1
	 									});
	 									registDefault(record.iedaDirectorConfigSeq, record.directorName);
	 									w2ui['config_directorGrid'].reset();
	 									},
	 				no_callBack		: function(envent){ 
	 										w2ui['config_directorGrid'].reset();
	 		        						doSearch();
	 		    						}
	 			});
 			}
 		}
	});
 	
 	/********************************************************
 	 * 설명 :  설정 관리자 추가 버튼
 	 *********************************************************/
	$("#addSetting").click(function(){
		w2popup.open({
			title 	: "<b>설치관리자 설정추가</b>",
			width 	: 550,
			height	: 380,
			modal	: true,
			body	: $("#regPopupDiv").html(),
			buttons : $("#regPopupBtnDiv").html(),
			onClose:function(event){
				doSearch();
			}
		});
	});
 	
	/********************************************************
	 * 설명 :  설정 관리자 수정 버튼
	 *********************************************************/
	$("#updateSetting").click(function(){
		if($("#updateSetting").attr('disabled') == "disabled") return;
		
		var selected = w2ui['config_directorGrid'].getSelection();
		
		if( selected.length == 0 ){
			w2alert("선택된 정보가 없습니다.", "설치 관리자 정보 수정");
			return;
		}
		updateDirectorConfigPopup(w2ui['config_directorGrid'].get(selected));
	});
	
	/********************************************************
	 * 설명 :  설정관리자 삭제 버튼
	 *********************************************************/
	$("#deleteSetting").click(function(){
		if($("#deleteSetting").attr('disabled') == "disabled") return;

		var selected = w2ui['config_directorGrid'].getSelection();
		
		if( selected.length == 0 ){
			w2alert("선택된 정보가 없습니다.", "설치 관리자 삭제");
			return;
		}
		else {
			var record = w2ui['config_directorGrid'].get(selected);

			w2confirm({
				title		: "설치 관리자 삭제",
				msg			: "설치 관리자(" + record.directorName + ")를 삭제하시겠습니까?",
				yes_text	: "확인",
				no_text		: "취소",
				yes_callBack: function(event){
					// 디렉터 삭제
					deleteDirector(record.iedaDirectorConfigSeq);
					
					// 기본 관리자일 경우 
					if ( record.defaultYn == "Y" ) {
						// 기본 설치 관리자 정보 조회
						$('.defaultDirector').text('');
					}
					w2ui['config_directorGrid'].clear();
					
					initView();
				},
				no_callBack	: function(){
					w2ui['config_directorGrid'].reset();
					doSearch();
				}
						
			});
		}
	});// 설정관리자 삭제 버튼 END
});

/********************************************************
 * 설명		: 목록 재조회
 * Function	: initView
 *********************************************************/
function initView() {
	// 기본 설치 관리자 정보 조회
 	getDefaultDirector("<c:url value='/common/use/director'/>");
	// 설치관리자 목록조회
	doSearch();
}

/********************************************************
 * 설명		: 목록 조회
 * Function	: doSearch
 *********************************************************/
function doSearch() {
	w2ui['config_directorGrid'].load("<c:url value='/config/director/list'/>", doButtonStyle);
}

/********************************************************
 * 설명		: 버튼 스타일 초기화
 * Function	: doButtonStyle
 *********************************************************/
function doButtonStyle(){
	var girdTotal = w2ui['config_directorGrid'].records.length;
	
	$('#setDefaultDirector').attr('disabled', true);
	$('#updateSetting').attr('disabled', true);
	$('#deleteSetting').attr('disabled', true);
}

/********************************************************
 * 설명		: 유효성 검사
 * Function	: validateInputField
 *********************************************************/
function validateInputField(inputField, value) {
	var isOk = true;
	
	switch ( inputField ) {
	case 'ip':
		if ( value.length <= 7 || !validateIP(value) ) {
			setGuideMessage($(".w2ui-msg-body #ipSuccMsg"), "", $(".w2ui-msg-body #ipErrMsg"), "IP주소를 정확히 입력하세요.");
			isOk = false;
		} else {
			setGuideMessage($(".w2ui-msg-body #ipSuccMsg"), "OK", $(".w2ui-msg-body #ipErrMsg"), "");
			isOk = true;
		}
		break;
	case 'port':
		if ( value <= 0 ) {
			setGuideMessage($(".w2ui-msg-body #portSuccMsg"), "", $(".w2ui-msg-body #portErrMsg"), "포트번호를 정확히 입력하세요.");
			isOk = false;
		}
		else {
			setGuideMessage($(".w2ui-msg-body #portSuccMsg"), "OK", $(".w2ui-msg-body #portErrMsg"), "");
			isOk = true;
		}

		break;
	case 'user':
		if ( value.length <= 3 ) {
			setGuideMessage($(".w2ui-msg-body #userSuccMsg"), "", $(".w2ui-msg-body #userErrMsg"), "계정을 입력하세요.(4자리 이상)");
			isOk = false;			
		} else {
			setGuideMessage($(".w2ui-msg-body #userSuccMsg"), "OK", $(".w2ui-msg-body #userErrMsg"), "");
			isOk = true;
		}
		break;
	case 'pwd':
		if ( value.length <= 3 ) {
			setGuideMessage($(".w2ui-msg-body #pwdSuccMsg"), "", $(".w2ui-msg-body #pwdErrMsg"), "비밀번호를 입력하세요.(4자리 이상)");
			isOk = false;
			
		} else {
			setGuideMessage($(".w2ui-msg-body #pwdSuccMsg"), "OK", $(".w2ui-msg-body #pwdErrMsg"), "");
			isOk = true;
		}
		break;
	}
	
	return isOk;
}

/********************************************************
 * 설명		: 유효성 검사 IP
 * Function	: validateIP
 *********************************************************/
function validateIP(input)  {
	if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(input))  
		return true;
	else 
		return false;  
}

/********************************************************
 * 설명		: 유효성 검사
 * Function	: setGuideMessage
 *********************************************************/
function setGuideMessage(successObject, successMessage, errorObject, errorMessage) {
	if ( successMessage == "" )
		successObject.html(successMessage);
	else {
		errorObject.css("color", "grey");
		successObject.html(successMessage).show().fadeOut(fadeOutTime);
	}
	
	errorObject.css("color", "red");
	errorObject.html(errorMessage);
}

/********************************************************
 * 설명		: 유효성 검사
 * Function	: validateAllInputField
 *********************************************************/
function validateAllInputField() {
	var isOk = true;
	if ( !validateInputField('ip', $(".w2ui-msg-body input[name='ip']").val()) )
		isOk = false;
	if ( !validateInputField('port', $(".w2ui-msg-body input[name='port']").val()) )
		isOk = false;
	if ( !validateInputField('user', $(".w2ui-msg-body input[name='user']").val()) )
		isOk = false;
	if ( !validateInputField('pwd', $(".w2ui-msg-body input[name='pwd']").val()) )
		isOk = false;

	return isOk;
}

/********************************************************
 * 설명		: 기본 설치 관리자 설정
 * Function	: registDefault
 *********************************************************/
function registDefault(seq, target){
	$.ajax({
		type : "PUT",
		url : "/config/director/setDefault/"+seq,
		contentType : "application/json",
		success : function(data, status) {
			w2alert("기본 설치 관리자를 \n" + target +"로 설정하였습니다.",  "기본 설치 관리자 설정", doSearch);
			getDefaultDirector("<c:url value='/common/use/director'/>");
		},
		error : function(request, status, error) {
			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message, "기본 설치 관리자 설정");
			doSearch();
		}
	});
}

/********************************************************
 * 설명		: 설정관리자 등록
 * Function	: registDirectorConfig
 *********************************************************/
function registDirectorConfig(){
	if ( !validateAllInputField() ) {
		return;
	}
	
	lock( '등록 중입니다.', true);

	$.ajax({
		type : "POST",
		url : "/config/director/add",
		contentType : "application/json",
		//dataType: "json",
		async : true,
		data : JSON.stringify({
			directorUrl : $(".w2ui-msg-body input[name='ip']").val(),
			directorPort : parseInt($(".w2ui-msg-body input[name='port']").val()),
			userId : $(".w2ui-msg-body input[name='user']").val(),
			userPassword : $(".w2ui-msg-body input[name='pwd']").val(),
		}),
		success : function(data, status) {
			
			w2popup.unlock();
			w2popup.close();
			doSearch();
			
			// 기본 설치 관리자 정보 조회
		 	getDefaultDirector("<c:url value='/common/use/director'/>");
		},
		error : function(request, status, error) {
			// ajax가 실패할때 처리...
			w2popup.unlock();
			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message);
			doSearch();
		}
	});
}

/********************************************************
 * 설명		: 설정관리자 수정 팝업
 * Function	: updateDirectorConfigPopup
 *********************************************************/
function updateDirectorConfigPopup(record) {
	
	w2confirm({
		title 	: "설치 관리자 정보 수정",
		msg		: "설치 관리자("+record.directorName+")를 수정하시겠습니까?",
		yes_text: "확인",
		yes_callBack : function(envent){
 			w2popup.open({
				title 	: "<b>설치관리자 정보수정</b>",
				width 	: 550,
				height	: 380,
				modal	: true,
				body	: $("#regPopupDiv").html(),
				buttons : $("#updatePopupBtnDiv").html(),
				onOpen : function(event){
					event.onComplete = function(){
						$(".w2ui-msg-body input[name='seq']").val(record.iedaDirectorConfigSeq);
						$(".w2ui-msg-body input[name='ip']").val(record.directorUrl);
						$(".w2ui-msg-body input[name='ip']").attr("disabled", true);
						$(".w2ui-msg-body input[name='port']").val(record.directorPort);
						$(".w2ui-msg-body input[name='port']").attr("disabled", true);
						$(".w2ui-msg-body input[name='user']").val(record.userId);
						$(".w2ui-msg-body input[name='pwd']").val("");
					}
				},onClose : function(event){
					w2ui['config_directorGrid'].reset();
					doSearch();
				}
			});

		},
		no_text : "취소",
		no_callBack : function(envent){
			w2ui['config_directorGrid'].reset();
			doSearch();
		}
	});
}

/********************************************************
 * 설명		: 설정관리자 수정 
 * Function	: updateDirectorConfig
 *********************************************************/
function updateDirectorConfig() {
	if ( !validateAllInputField() ) {
		return;
	}
	lock( '수정 중입니다.', true);

	$.ajax({
		type : "PUT",
		url : "/config/director/update/" + $(".w2ui-msg-body input[name='seq']").val(),
		contentType : "application/json",
		async : true,
		data : JSON.stringify({
			iedaDirectorConfigSeq : parseInt($(".w2ui-msg-body input[name='seq']").val()),
			userId : $(".w2ui-msg-body input[name='user']").val(),
			userPassword : $(".w2ui-msg-body input[name='pwd']").val()
		}),
		success : function(data, status) {
			// ajax가 성공할때 처리...
			w2popup.unlock();
			w2popup.close();
			w2ui['config_directorGrid'].reset();
			doSearch();
			
			// 기본 설치 관리자 정보 조회
		 	getDefaultDirector("<c:url value='/common/use/director'/>");
		},
		error : function(request, status, error) {
			// ajax가 실패할때 처리...
			w2popup.unlock();
			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message);
			doSearch();
		}
	});
}

/********************************************************
 * 설명		: 설정관리자 삭제 
 * Function	: deleteDirector
 *********************************************************/
function deleteDirector(seq){
	$.ajax({
		type : "DELETE",
		url : "/config/director/delete/"+ seq,
		contentType : "application/json",
		success : function(data, status) {
			// ajax가 성공할때 처리...
			doSearch();
			w2popup.unlock();
			w2popup.close();
		},
		error : function(request, status, error) {
			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message, "설치 관리자 삭제");
			doSearch();
		}
	});
}

function closew2ui(){
	w2popup.close();
	doSearch();
}

/********************************************************
 * 설명		: 다른 페이지 호출
 * Function	: clearMainPage
 *********************************************************/
function clearMainPage() {
	$().w2destroy('config_directorGrid');
}

/********************************************************
 * 설명		: lock 실행
 * Function	: lock
 *********************************************************/
function lock (msg) {
    w2popup.lock(msg, true);
}
</script>

<div id="main">
	<div class="page_site">환경설정 및 관리 > <strong>설치관리자 설정</strong></div>
	
	<!-- 설치 관리자 정보 -->
	<div id="isDefaultDirector"></div>
	
	<!-- 설치관리자 목록-->
	<div class="pdt20">
		<div class="title fl">설치관리자 목록</div>
		<div class="fr"> 
		<!-- Btn -->
		<sec:authorize access="hasAuthority('CONFIG_DIRECTOR_SET')">
		<span id="setDefaultDirector" class="btn btn-primary" style="width:180px" >기본 설치 관리자로 설정</span>
		</sec:authorize>
		<sec:authorize access="hasAuthority('CONFIG_DIRECTOR_ADD')">
		<span id="addSetting" class="btn btn-primary" style="width:130px" >설정 추가</span>
		</sec:authorize>
		<sec:authorize access="hasAuthority('CONFIG_DIRECTOR_UPDATE')">
		<span id="updateSetting" class="btn btn-info" style="width:130px" >설정 수정</span>
		</sec:authorize>
		<sec:authorize access="hasAuthority('CONFIG_DIRECTOR_DELETE')">
		<span id="deleteSetting" class="btn btn-danger" style="width:130px" >설정 삭제</span>
		</sec:authorize>
		<!-- //Btn -->
	    </div>
	</div>
	
	<!-- 설치관리자 목록 조회-->
	<div id="config_directorGrid" style="width:100%; height:610px"></div>	
</div>

<!-- 설치관리자 정보추가/수정 팝업 -->
<div id="regPopupDiv" hidden="true">
	<form id="settingForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
		<div class="panel panel-info" >	
			<div class="panel-heading"><b>설치관리자 정보</b></div>
			<div class="panel-body" style="padding:5px 5% 10px 5%;height:210px;">
				<div class="w2ui-field">
					<label style="width:30%;text-align: left;padding-left: 20px;">디렉터 IP</label>
					<div style="width: 70%;">
						<input name="ip" type="url" maxlength="100" style="width: 250px" required="required" placeholder="xxx.xx.xx.xxx" onchange="validateInputField('ip', this.value)"/>
						<span id="ipSuccMsg"></span><BR><span id="ipErrMsg"></span>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="width:30%;text-align: left;padding-left: 20px;">포트번호</label>
					<div style="width: 70%;">
						<input name="port" type="number" maxlength="100" style="width: 250px" required="required" min="50" placeholder="25555" onchange="validateInputField('port', this.value)"/>
						<span id="portSuccMsg"></span><BR><span id="portErrMsg"></span>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="width:30%;text-align: left;padding-left: 20px;">계정</label>
					<div style="width: 70%">
						<input name="user" type="text" maxlength="100" style="width: 250px" required="required" placeholder="admin" onchange="validateInputField('user', this.value)"/>
						<span id="userSuccMsg"></span><BR><span id="userErrMsg" style="color:'red'"></span>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="width:30%;text-align: left;padding-left: 20px;">비밀번호</label>
					<div style="width: 70%;">
						<input name="pwd" type="password" maxlength="100" style="width: 250px" required="required" placeholder="admin" onchange="validateInputField('pwd', this.value)"/>
						<span id="pwdSuccMsg"></span><BR><span id="pwdErrMsg"></span>
					</div>
				</div>
				<input name="seq" type="hidden"/>
			</div>
		</div>
	</form>	
</div>

<div id="regPopupBtnDiv" hidden="true">
	<button class="btn" id="registBtn" onclick="registDirectorConfig();">확인</button>
	<button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

<div id="updatePopupBtnDiv" hidden="true">
	<button class="btn" id="updateBtn" onclick="updateDirectorConfig();">확인</button>
	<button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

