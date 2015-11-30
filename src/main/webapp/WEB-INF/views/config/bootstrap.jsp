<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" type="text/css" href="/css/bootstrap-progress-step.css"/>
<style type="text/css">
.w2ui-popup .w2ui-msg-body{background-color: #FFF; }
</style>
<script type="text/javascript">

//private variable
var structureType = "";
var awsInfo = "";
var networkInfo = "";
var resourcesInfo = "";
var deployInfo = "";

$(function() {
	
 	$('#config_bootstrapGrid').w2grid({
		name: 'config_bootstrapGrid',
		method: 'GET',
		show: {	
			lineNumbers: true,
			selectColumn: true,
			footer: true},
		multiSelect: false,
		style: 'text-align:center',
		columns:[
			 {field: 'status', caption: '상태', size: '20%'}
			,{field: 'name', caption: '이름', size: '20%'}
			,{field: 'iaas', caption: 'IaaS', size: '20%'}
			,{field: 'ip', caption: 'IP', size: '40%'}
			],
		onClick:function(event) {
			var grid = this;
			event.onComplete = function() {
				var sel = grid.getSelection();
				console.log("##### sel ::: " + sel);
				if ( sel == null || sel == "") {
					$('#bootstrapDeleteBtn').attr('disabled', true);
					return;
				}
			}
		}
	});
 	
 	//BootStrap 설치
 	$("#bootstrapInstallBtn").click(function(){
 		bootSetPopup();
 	});
 	
 	//BootStrap 삭제
	$("#bootstrapDeleteBtn").click(function(){
		if($("#bootstrapDeleteBtn").attr('disabled') == "disabled") return;
 	});

	doSearch();
});

//조회기능
function doSearch() {
	doButtonStyle();
	//w2ui['config_bootstrapGrid'].load("<c:url value='/bootstaps'/>", doButtonStyle);
}

function doButtonStyle(){
	//삭제 버튼 hide
	$('#bootstrapDeleteBtn').attr('disabled', true);// 기본관리자 설정 Disable
}

//다른페이지 이동시 호출
function clearMainPage() {
	$().w2destroy('config_bootstrapGrid');
}

//화면 리사이즈시 호출
$( window ).resize(function() {
	setLayoutContainerHeight();
});


//Bootstrap 
function bootSetPopup() {
	w2confirm({
		width 			: 500,
		height 			: 180,
		title 			: '<b>BOOTSTRAP 설치</b>',
		msg 			: $("#bootSelectBody").html(),
		yes_text 		: "확인",
		no_text 		: "취소",
		yes_callBack 	: function(){
			//alert($("input[name='structureType']").val());
			if($(".w2ui-msg-body input[name='structureType']").val() != ""){
				structureType = $("input[name='structureType']").val(); 
				awsPopup();
			}
			else{
				w2alert("설치할 Infrastructure 을 선택하세요");
			}
		}
	});
}

//AWS Info Setting Popup
function awsPopup(){
	$("#awsSettingInfoDiv").w2popup({
		width : 610,
		height : 390,
		onClose : initSetting,
		onOpen:function(){
			setAwsData();
		}
	});
}

function setAwsData(){
	//set Data
	$(".w2ui-msg-body input[name='awsKey']").val("test-awsKey");
	$(".w2ui-msg-body input[name='awsPw']").val("test-awsPw");
	$(".w2ui-msg-body input[name='securGroupName']").val("test-securGroupName");
	$(".w2ui-msg-body input[name='privateKeyName']").val("test-privateKeyName");
	$(".w2ui-msg-body input[name='privateKeyPath']").val("test-privateKeyPath");
}

//Save AWS Setting Info
function saveAwsSettingInfo(){
	awsInfo = {
			awsKey			: $(".w2ui-msg-body input[name='awsKey']").val(),
			awsPw			: $(".w2ui-msg-body input[name='awsPw']").val(),
			securGroupName	: $(".w2ui-msg-body input[name='securGroupName']").val(),
			privateKeyName	: $(".w2ui-msg-body input[name='privateKeyName']").val(),
			privateKeyPath	: $(".w2ui-msg-body input[name='privateKeyPath']").val()
	}
	
	$.ajax({
		type : "POST",
		url : "/bootstrap/bootSetAwsSave",
		contentType : "application/json",
		//dataType: "json",
		async : true,
		data : JSON.stringify(awsInfo), 
		success : function(data, status) {
			networkPopup();
		},
		error : function( e, status ) {
			w2alert("AWS 설정 등록에 실패 하였습니다.", "BOOTSTRAP 설치");
		}
	});
}

//Network Info Setting Popup
function networkPopup(){
	$("#networkSettingInfoDiv").w2popup({
		width : 610,
		height : 420,
		onClose : initSetting,
		onOpen : function(){
			setNetworkData();	
		}
	});
}

function setNetworkData(){
	$(".w2ui-msg-body input[name='subnetRange']").val("52.21.37.180 to 52.21.37.184");
	$(".w2ui-msg-body input[name='gateway']").val("52.21.37.1");
	$(".w2ui-msg-body input[name='dns']").val("52.21.37.184");
	$(".w2ui-msg-body input[name='subnetId']").val("test-subnetId");
	$(".w2ui-msg-body input[name='directorPrivateIp']").val("127.0.0.1");
	$(".w2ui-msg-body input[name='directorPublicIp']").val("52.23.2.85");
}

//Save Network Setting Info
function saveNetworkSettingInfo(param){
	networkInfo = {
			key					: awsInfo.awsKey,
			subnetRange			: $(".w2ui-msg-body input[name='subnetRange']").val(),
			gateway				: $(".w2ui-msg-body input[name='gateway']").val(),
			dns					: $(".w2ui-msg-body input[name='dns']").val(),
			subnetId			: $(".w2ui-msg-body input[name='subnetId']").val(),
			directorPrivateIp	: $(".w2ui-msg-body input[name='directorPrivateIp']").val(),
			directorPublicIp	: $(".w2ui-msg-body input[name='directorPublicIp']").val()
	}
	
	$.ajax({
		type : "POST",
		url : "/bootstrap/bootSetNetworkSave",
		contentType : "application/json",
		//dataType: "json",
		async : true,
		data : JSON.stringify(networkInfo), 
		success : function(data, status) {
			if(param == 'after') resourcesPopup();
			else awsPopup();				
		},
		error : function( e, status ) {
			w2alert("네트워크 설정 등록에 실패 하였습니다.", "BOOTSTRAP 설치");
		}
	});
}


function resourcesPopup(){
	//getStemcellList();
	$("#resourcesSettingInfoDiv").w2popup({
		width : 610,
		height : 400,
		onOpen : function(){
			getStemcellList();//스템셀 리스트 가져오기
			setReleaseData();
		},
		onClose : initSetting
	});
}
function setReleaseData(){
	//targetStemcell	: $(".w2ui-msg-body input[name='targetStemcell']").val(),
	$(".w2ui-msg-body input[name='instanceType']").val("microbosh");
	$(".w2ui-msg-body input[name='availabilityZone']").val("openstack_01");
	$(".w2ui-msg-body input[name='microBoshPw']").val("test-microBoshPw");
}

function getStemcellList(){
	$.ajax({
		type : "GET",
		url : "/bootstrap/getLocalStemcellList",
		contentType : "application/json",
		//dataType: "json",
		async : true,
		success : function(data, status) {
			$('#w2ui-popup input[type=list]').w2field('list', { items: data , maxDropHeight:300, width:500});
		},
		error : function( e, status ) {
			w2alert("스템셀 목록을 가져오는데 실패하였습니다.", "BOOTSTRAP 설치");
		}
	});
}

function saveResourcesSettingInfo(param){
	resourcesInfo = {
			key				: awsInfo.awsKey,
			targetStemcell	: $(".w2ui-msg-body input[name='targetStemcell']").val(),
			instanceType	: $(".w2ui-msg-body input[name='instanceType']").val(),
			availabilityZone: $(".w2ui-msg-body input[name='availabilityZone']").val(),
			microBoshPw		: $(".w2ui-msg-body input[name='microBoshPw']").val(),
			nextType		: param
	}
	
	$.ajax({
		type : "POST",
		url : "/bootstrap/bootSetResourcesSave",
		contentType : "application/json",
		//dataType: "json",
		async : true,
		data : JSON.stringify(resourcesInfo), 
		success : function(data, status) {
			if( param == 'after') deployPopup();
			else networkPopup();
		},
		error : function( e, status ) {
			w2alert("리소스 설정 등록에 실패 하였습니다.", "BOOTSTRAP 설치");
		}
	});
}

function deployPopup(){
	$("#deployManifestDiv").w2popup({
		width 	: 610,
		height 	: 470,
		onClose : initSetting,
		onOpen :function(){
			getDeployInfo();
		}
	});
}

function getDeployInfo(){
	$.ajax({
		type : "POST",
		url : "/bootstrap/getBootStrapSettingInfo",
		contentType : "application/json",
		//dataType: "json",
		async : true, 
		success : function(data, status) {
			if(status == "success"){
				//deployInfo = data;
				$(".w2ui-msg-body #deployInfo").text(data);
			}
			else if(status == "204"){
				w2alert("sampleFile이 존재하지 않습니다.", "BOOTSTRAP 설치");
			}
		},
		error : function( e, status ) {
			w2alert("Temp 파일을 가져오는 중 오류가 발생하였습니다. ", "BOOTSTRAP 설치");
		}
	});
}

function saveDeployInfo(param){
	//Deploy 단에서 저장할 데이터가 있는지 확인 필요
	//Confirm 설치하시겠습니까?
	if(param == 'after'){		
		w2confirm({
			msg			: "설치하시겠습니까?",
			title		: w2utils.lang('BOOTSTRAP 설치'),
			yes_text	: "예",
			no_text		: "아니오",
			yes_callBack: installPopup
			
		});
	}
	else{
		resourcesPopup();
	}
}

function installPopup(){
	$("#installDiv").w2popup({
		width : 610,
		height : 470,
		onOpen : function(){
			//1.Install
			//2.소켓연결(설치 로그)
			w2alert("socket연결");
		},
		onClose : initSetting
	});
}

//팝업창 닫을 경우
function initSetting(){
	structureType 	= null;
	awsInfo			= null;
	networkInfo 	= null;
	resourcesInfo 	= null;
	deployInfo 		= null;
}

function uploadStemcell(){
	$("#targetStemcellUpload").click();
}

</script>

<div id="main">
	<div class="page_site">설치관리자 환경설정 > <strong>BOOTSTRAP 설치</strong></div>
	
	<!-- 설치 관리자 -->
<!-- 	<div class="title">설치 관리자</div>
	
	<table class="tbl1" border="1" cellspacing="0">
	<tr>
		<th width="18%" class="th_fb">관리자 이름</th><td class="td_fb">0000</td>
		<th width="18%" class="th_fb">관리자 계정</th><td class="td_fb">0000</td>
	</tr>
	<tr>
		<th width="18%" >관리자 URL</th><td>0000</td>
		<th width="18%" >관리자 UUID</th><td >0000</td>
	</tr>
	</table>
	
	<div id="hMargin"/>
 -->
 
	<!-- BOOTSTRAP 목록-->
	<div class="pdt20"> 
		<div class="title fl">BOOTSTRAP 목록</div>
		<div class="fr"> 
			<!-- Btn -->
			<span id="bootstrapInstallBtn" class="btn btn-primary"  style="width:130px">BOOTSTRAP 설치</span>
			<span id="bootstrapDeleteBtn" class="btn btn-danger" style="width:130px">BOOTSTRAP 삭제</span>
			<!-- //Btn -->
	    </div>
	</div>
	<div id="config_bootstrapGrid" style="width:100%; height:500px"></div>	
	
</div>

<!-- Start Popup Resion -->
	<!-- Infrastructure  설정 DIV -->
	<div id="bootSelectBody" style="width:100%; height: 80px;" hidden="true">
		<div class="w2ui-lefted" style="text-align: left;">
			설치할 Infrastructure 을 선택하세요<br />
			<br />
		</div>
		<div class="col-sm-9">
			<div class="btn-group" data-toggle="buttons" >
				<label style="width: 100px;margin-left:40px;">
					<input type="radio" name="structureType" id="type1" value="AWS" checked="checked" />
					&nbsp;AWS
				</label>
				<label style="width: 130px;margin-left:50px;">
					<input type="radio" name="structureType" id="type2" value="OPENSTACK"  />
					&nbsp;OPENSTACK
				</label>
			</div>
		</div>
	</div>

	<!-- AWS  설정 DIV -->
	<div id="awsSettingInfoDiv" style="width:100%;height:100%;" hidden="true">
		<div rel="title"><b>BOOTSTRAP 설치</b></div>
		<div rel="body" style="width:100%;padding:15px 5px 15px 5px;">
			<div rel="sub-title" >
	            <ul class="progressStep" >
		            <li class="active">AWS 설정</li>
		            <li class="before">Network 설정</li>
		            <li class="before">리소스 설정</li>
		            <li class="before">배포 Manifest</li>
		            <li class="before">설치</li>
	            </ul>
	        </div>
			<div class="cont_title">▶ AWS 설정정보</div>
		    <div class="w2ui-page page-0" style="padding-left:5%;">
		        <div class="w2ui-field">
		            <label style="text-align: left;width:250px;font-size:11px;">AWS 키(access-key)</label>
		            <div>
		                <input name="awsKey" type="text" maxlength="100" size="30" style="float:left;width:280px;"/>
		            </div>
		        </div>
		        <div class="w2ui-field">
		            <label style="text-align: left;width:250px;font-size:11px;">AWS 비밀번호(secret-access-key)</label>
		            <div>
		                <input name="awsPw" type="password" maxlength="100" size="30" style="float:left;width:280px;"/>
		            </div>
		        </div>
		        <div class="w2ui-field">
		            <label style="text-align: left;width:250px;font-size:11px;">시큐리티 그룹명</label>
		            <div>
		                <input name="securGroupName" type="text" maxlength="100" size="30" style="float:left;width:280px;"/>
		            </div>
		        </div>
		        <div class="w2ui-field">
		            <label style="text-align: left;width:250px;font-size:11px;">Private Key 명</label>
		            <div>
		                <input name="privateKeyName" type="text" maxlength="100" size="30" style="float:left;width:280px;"/>
		            </div>
		        </div>
		        <div class="w2ui-field">
		            <label style="text-align: left;width:250px;font-size:11px;">Private Key Path</label>
		            <div>
		                <input name="privateKeyPath" type="text" maxlength="100" size="30" style="float:left;width:280px;"/>
		            </div>
		        </div>
		    </div>
			<br/>
		    <div class="w2ui-buttons" rel="buttons" hidden="true">
		        <button class="btn" style="float: left;" onclick="w2popup.close();">취소</button>
		        <button class="btn" style="float: right;padding-right:15%" onclick="saveAwsSettingInfo();">다음>></button>
		    </div>
		</div>
	</div>
	
	
	<!-- Network  설정 DIV -->
	<div id="networkSettingInfoDiv" style="width:100%;height:100%;" hidden="true">
		<div rel="title"><b>BOOTSTRAP 설치</b></div>
		<div rel="body" style="width:100%;padding:15px 5px 15px 5px;">
			<div >
	            <ul class="progressStep">
		            <li class="pass">AWS 설정</li>
		            <li class="active">Network 설정</li>
		            <li class="before">리소스 설정</li>
		            <li class="before">배포 Manifest</li>
		            <li class="before">설치</li>
	            </ul>
	        </div>
			<div rel="sub-title" class="cont_title">▶ Network 설정정보</div>
			<div class="w2ui-page page-0" style="padding-left: 5%;">
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">Subnet Range</label>
					<div>
						<input name="subnetRange" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">Gateway</label>
					<div>
						<input name="gateway" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">DNS</label>
					<div>
						<input name="dns" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">Subnet ID</label>
					<div>
						<input name="subnetId" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">Director Private IP</label>
					<div>
						<input name="directorPrivateIp" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">Director Public IP</label>
					<div>
						<input name="directorPublicIp" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
			</div>
			<br />
			<div class="w2ui-buttons" rel="buttons" hidden="true">
				<button class="btn" style="float: left;" onclick="saveNetworkSettingInfo('before');">이전</button>
				<button class="btn" onclick="w2popup.close();">취소</button>
				<button class="btn" style="float: right; padding-right: 15%" onclick="saveNetworkSettingInfo('after');">다음>></button>
			</div>
		</div>
	</div>
	
	<!-- Resources  설정 DIV -->
	<div id="resourcesSettingInfoDiv" style="width:100%;height:100%;" hidden="true">
		<div rel="title"><b>BOOTSTRAP 설치</b></div>
		<div rel="body" style="width:100%;padding:15px 5px 15px 5px;">
			<div >
	            <ul class="progressStep">
		            <li class="pass">AWS 설정</li>
		            <li class="pass">Network 설정</li>
		            <li class="active">리소스 설정</li>
		            <li class="before">배포 Manifest</li>
		            <li class="before">설치</li>
	            </ul>
	        </div>
			<div rel="sub-title" class="cont_title">▶ 리소스 설정정보</div>
			<div class="w2ui-page page-0" style="padding-left: 5%;">
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">스템셀 지정</label>
					<div>
						<!-- <input name="targetStemcell" type="text" maxlength="100" style="float: left;width:330px;margin-top:1.5px;" /> -->
						<div><input type="list" name="targetStemcell" style="float: left;width:330px;margin-top:1.5px;"></div>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">인스턴스 유형</label>
					<div>
						<input name="instanceType" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">Availability Zone</label>
					<div>
						<input name="availabilityZone" type="text" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
				<div class="w2ui-field">
					<label style="text-align: left; width: 200px; font-size: 11px;">MicroBOSH Password</label>
					<div>
						<input name="microBoshPw" type="password" maxlength="100" size="30" style="float:left;width:330px;"/>
					</div>
				</div>
			</div>
			<br />
			<div class="w2ui-buttons" rel="buttons" hidden="true">
				<button class="btn" style="float: left;" onclick="saveResourcesSettingInfo('before');">이전</button>
				<button class="btn" onclick="w2popup.close();">취소</button>
				<button class="btn" style="float: right; padding-right: 15%" onclick="saveResourcesSettingInfo('after');">다음>></button>
			</div>
		</div>
	</div>
	
	<div id="deployManifestDiv" style="width:100%;height:100%;" hidden="true">
		<div rel="title"><b>BOOTSTRAP 설치</b></div>
		<div rel="body" style="width:100%;padding:15px 5px 15px 5px;">
			<div >
	            <ul class="progressStep">
		            <li class="pass">AWS 설정</li>
		            <li class="pass">Network 설정</li>
		            <li class="pass">리소스 설정</li>
		            <li class="active">배포 Manifest</li>
		            <li class="before">설치</li>
	            </ul>
	        </div>
			<div rel="sub-title" class="cont_title">▶ 배포 Manifest 정보</div>
			<div>
				<textarea id="deployInfo" style="width:95%;height:250px;overflow-y:visible;resize:none;background-color: #FFF;margin-left:1%" readonly="readonly"></textarea>
			</div>
		</div>
		<div class="w2ui-buttons" rel="buttons" hidden="true">
			<button class="btn" style="float: left;" onclick="saveDeployInfo('before');">이전</button>
			<button class="btn" onclick="w2popup.close();">취소</button>
			<button class="btn" style="float: right; padding-right: 15%" onclick="saveDeployInfo('after');">다음>></button>
		</div>
	</div>
	
	<div id="installDiv" style="width:100%;height:100%;" hidden="true">
		<div rel="title"><b>BOOTSTRAP 설치</b></div>
		<div rel="body" style="width:100%;padding:15px 5px 15px 5px;">
			<div >
	            <ul class="progressStep">
		            <li class="pass">AWS 설정</li>
		            <li class="pass">Network 설정</li>
		            <li class="pass">리소스 설정</li>
		            <li class="pass">배포 Manifest</li>
		            <li class="active">설치</li>
	            </ul>
	        </div>
			<div rel="sub-title" class="cont_title">▶ 설치 로그</div>
			<div>
				<textarea id="installLogs" style="width:95%;height:250px;overflow-y:visible;resize:none;background-color: #FFF;margin-left:1%" readonly="readonly"></textarea>
			</div>
		</div>
		<div class="w2ui-buttons" rel="buttons" hidden="true">
				<!-- 설치 실패 시 -->
				<button class="btn" style="float: left;" onclick="saveDeployInfo('before');">이전</button>
				<button class="btn" onclick="w2popup.close();">취소</button>
				<button class="btn" style="float: right; padding-right: 15%" onclick="w2popup.close();">완료</button>
		</div>		
	</div>	
<!-- End Popup Resion -->