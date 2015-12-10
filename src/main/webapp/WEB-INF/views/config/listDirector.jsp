<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script type="text/javascript">

$(function() {
	
  	$('#config_directorGrid').w2grid({
		name: 'config_directorGrid',
		header: '<b>설치관리자 목록</b>',
 		method: 'GET',
 		multiSelect: false,
		show: {	
				lineNumbers: true,
				selectColumn: true,
				footer: true},
		style: 'text-align: center',
		columns:[
				 {field: 'recid', 					caption: 'recid', 		hidden: true},
		         {field: 'iedaDirectorConfigSeq', 	caption: '레코드키', 		hidden: true},
		         {field: 'defaultYn', 				caption: '기본 관리자',	size: '10%',
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
		onClick:function(event) {
			var grid = this;
			event.onComplete = function() {
				var sel = grid.getSelection();
				if ( sel == null || sel == "") {
					$('#setDefaultDirector').attr('disabled', true);
					$('#deleteSetting').attr('disabled', true);
					return;
				}
				
				var record = grid.get(sel);
				if ( record.defaultYn == 'Y' ) {
					$('#setDefaultDirector').attr('disabled', true);// 기본관리자 설정 Disable
				}
				else {
					$('#setDefaultDirector').attr('disabled', false);// 기본관리자 설정 Enable
				}
				
				$('#deleteSetting').attr('disabled', false);
			}
		},
		onError: function(event) {
			this.unlock();
			gridErrorMsg(event);
		}
	});
  	
 	initView();
 	
 	//기본관리자 설정
 	$("#setDefaultDirector").click(function(){
 		if($("#setDefaultDirector").attr('disabled') == "disabled") return;
 		
 		var selected = w2ui['config_directorGrid'].getSelection();
 		if( selected.length == 0 ){
 			w2alert("선택된 정보가 없습니다.", "기본관리자 설정");
 			return;
 		}
 		else  if ( selected.length > 1 ){
 			w2alert("기본관리자 설정은 하나만 선택 가능합니다.", "기본관리자 설정");
 			return;
 		}
 		else{
 			var record = w2ui['config_directorGrid'].get(selected);
 			if( record.defaultYn == "Y" ){
 				//클릭시 버튼  Disable 
 				w2alert("선택한 설정관리자는 이미 기본관리자로 설정되어 있습니다.","기본관리자 설정");
 				return;
 			}
 			else{
	 			w2confirm(record.directorName + "를 " + "기본관리자로 설정하시겠습니까?","기본관리자 설정")
	 			.yes(function(){
	 				registDefault(record.iedaDirectorConfigSeq, record.directorName);
	 				w2ui['config_directorGrid'].reset();
	 			})
	 			.no(function () { 
	 		        console.log("user clicked NO")
	 		    });;
 			}
 		}
	});
		 			
	//설정 관리자 추가 버튼
	$("#addSetting").click(function(){
		w2popup.open({
			title 	: "<b>설치관리자 설정추가</b>",
			width 	: 600,
			height	: 250,
			body	: $("#regPopupDiv").html(),
			buttons : $("#regPopupBtnDiv").html()
		});
	});
	
	//설정관리자 삭제 버튼
	$("#deleteSetting").click(function(){
		if($("#deleteSetting").attr('disabled') == "disabled") return;

		var selected = w2ui['config_directorGrid'].getSelection();
		
		if( selected.length == 0 ){
			w2alert("선택된 정보가 없습니다.", "설치 관리자 삭제");
			return;
		}
		else {
			var record = w2ui['config_directorGrid'].get(selected);

			w2confirm("설치 관리자(" + record.directorName + ")를 삭제하시겠습니까?","설치 관리자 삭제")
				.yes(function(){
					// 디렉터 삭제
					deleteDirector(record.iedaDirectorConfigSeq);
					
					// 기본 관리자일 경우 
					if ( record.defaultYn == "Y" ) {
						// 기본 설치 관리자 정보 조회
						$('.defaultDirector').text('');
					}
					w2ui['config_directorGrid'].delete(record);
				})
				.no(function () { 
			        console.log("user clicked NO")
			    });
		}
	});//설정관리자 삭제 버튼 END
});

function initView() {
	// 기본 설치 관리자 정보 조회
 	getDefaultDirector("<c:url value='/directors/default'/>");

	// 설치관리자 목록조회
	doSearch();
}

//조회기능
function doSearch() {
	w2ui['config_directorGrid'].load("<c:url value='/directors'/>", doButtonStyle);
}

function doButtonStyle(){
	var girdTotal = w2ui['config_directorGrid'].records.length;
	
	//기본관리자 버튼 Hide
	$('#setDefaultDirector').attr('disabled', true);// 기본관리자 설정 Disable
	
	//삭제 버튼 hide
	$('#deleteSetting').attr('disabled', true);// 기본관리자 설정 Disable
}

//기본관리자 설정
function registDefault(seq, target){
	$.ajax({
		type : "PUT",
		url : "/director/default/"+seq,
		contentType : "application/json",
		success : function(data, status) {
			w2alert("기본 관리자를 \n" + target +"로 설정하였습니다.",  "기본관리자 설정", doSearch);
			
			getDefaultDirector("<c:url value='/directors/default'/>");
		},
		error : function(request, status, error) {

			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message, "기본관리자 설정");
		}
	});
}

//설정관리자 등록
function registSetting(){
	lock( '등록 중입니다.', true);

	$.ajax({
		type : "POST",
		url : "/directors",
		contentType : "application/json",
		//dataType: "json",
		async : true,
		data : JSON.stringify({
			userId : $(".w2ui-msg-body input[name='userId']").val(),
			userPassword : $(".w2ui-msg-body input[name='userPassword']").val(),
			directorUrl : $(".w2ui-msg-body input[name='directorUrl']").val(),
			directorPort : parseInt($(".w2ui-msg-body input[name='directorPort']").val())
		}),
		success : function(data, status) {
			// ajax가 성공할때 처리...
			w2popup.unlock();
			w2popup.close();
			
			doSearch();
			// 기본 설치 관리자 정보 조회
		 	getDefaultDirector("<c:url value='/directors/default'/>");
		},
		error : function(request, status, error) {
			// ajax가 실패할때 처리...
			w2popup.unlock();
			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message);
		}
	});
}

//설정관리자 삭제
function deleteDirector(seq){
	$.ajax({
		type : "DELETE",
		url : "/director/"+ seq,
		contentType : "application/json",
		success : function(data, status) {
			// ajax가 성공할때 처리...
			w2popup.unlock();
			w2popup.close();
		},
		error : function(request, status, error) {
			var errorResult = JSON.parse(request.responseText);
			w2alert(errorResult.message, "설치 관리자 삭제");
		}
	});
}

//다른페이지 이동시 호출
function clearMainPage() {
	$().w2destroy('config_directorGrid');
}

function lock (msg) {
    w2popup.lock(msg, true);
}
</script>

<div id="main">
	<div class="page_site">설치관리자 환경설정 > <strong>설치관리자 설정</strong></div>
	
	<!-- 설치 관리자 -->
	<div class="title">설치 관리자</div>
	
	<table class="tbl1" border="1" cellspacing="0">
	<tr>
		<th width="18%" class="th_fb">관리자 이름</th><td class="td_fb"><b class='defaultDirector' id="directorName"></b></td>
		<th width="18%" class="th_fb">관리자 계정</th><td class="td_fb"><b class='defaultDirector' id="userId"></b></td>
	</tr>
	<tr>
		<th width="18%" >관리자 URL</th><td><b class='defaultDirector' id="directorUrl"></b></td>
		<th width="18%" >관리자 UUID</th><td ><b class='defaultDirector' id="directorUuid"></b></td>
	</tr>
	</table>
	
	<!-- 설치관리자 목록-->
	<div class="pdt20">
		<div class="title fl">설치관리자 목록</div>
		<div class="fr"> 
		<!-- Btn -->
		<span id="setDefaultDirector" class="btn btn-primary" style="width:150px" >기본관리자로 설정</span>
		<span id="addSetting" class="btn btn-primary" style="width:130px" >설정 추가</span>
		<span id="deleteSetting" class="btn btn-danger" style="width:130px" >설정 삭제</span>
		<!-- //Btn -->
	    </div>
	</div>
	
	<div id="hMargin"></div>
	
	<div id="config_directorGrid" style="width:100%; height:500px"></div>	
</div>
<div id="regPopupDiv" hidden="true">
	<form id="addSettingForm" action="POST">
		<div class="w2ui-page page-0" style="width: 100%">
			<label>●&nbsp;설치관리자 설정 정보</label>
			<div class="w2ui-field">
				<label style="width:30%;text-align: left;padding-left: 20px;">관리자 계정명</label>
				<div style="width: 70%">
					<input name="userId" type="text" maxlength="100" style="width: 250px" required="required" value="admin"/>
				</div>
			</div>
			<div class="w2ui-field">
				<label style="width:30%;text-align: left;padding-left: 20px;">관리자 계정 비밀번호</label>
				<div style="width: 70%;">
					<input name="userPassword" type="password" maxlength="100" style="width: 250px" required="required" value="admin"/>
				</div>
			</div>
			<div class="w2ui-field">
				<label style="width:30%;text-align: left;padding-left: 20px;">디텍터 Url</label>
				<div style="width: 70%;">
					<input name="directorUrl" type="url" maxlength="100" style="width: 250px" required="required" value="52.23.2.85"/>
				</div>
			</div>
			<div class="w2ui-field">
				<label style="width:30%;text-align: left;padding-left: 20px;">디텍터 Port</label>
				<div style="width: 70%;">
					<input name="directorPort" type="number" maxlength="100" style="width: 250px" required="required" value="25555"/>
				</div>
			</div>
		</div>
	</form>	
</div>
<div id="regPopupBtnDiv" hidden="true">
	<button class="btn" id="registBtn"onclick="registSetting();">설정</button>
	<button class="btn" id="popClose" onclick="w2popup.close();">취소</button>
</div>
