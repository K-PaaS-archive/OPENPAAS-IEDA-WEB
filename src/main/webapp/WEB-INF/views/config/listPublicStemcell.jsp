<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script type="text/javascript">

$(function() {
	
 	$('#config_opStemcellsGrid').w2grid({
		name: 'config_opStemcellsGrid',
		show: {selectColumn: true, footer: true},

		multiSelect: false,
		method: 'GET',
		style: 'text-align:center',
		columns:[
			 {field: 'recid', caption: '운영체계', size:'10%'}
			,{field: 'os', caption: '운영체계', size: '10%'}
			,{field: 'osVersion', caption: '버전', size: '10%'}
			,{field: 'iaas', caption: 'IaaS', size: '10%', sortable: true}
			,{field: 'stemcellVersion', caption: '스템셀버전', size: '10%'}
			,{field: 'stemcellFileName', caption: '파일명', size: '40%'}
			,{field: 'download', caption: '다운로드여부', size: '10%', style: 'text-align:left'}
		]
		
	});

 	//  화면 초기화에 필요한 데이터 요청
 	initView();
 	
 	// 목록조회
 	$("#doSearch").click(function(){
 		doSearch();
    });
 	
 	//  스템셀 다운로드
 	$("#doDownload").click(function(){
    	doDownload();
    });
 	
 	//	스템셀 삭제
 	$("#doDelete").click(function(){
 		doDelete();
    });

});

function initView() {
	//  기본 설치관리자 정보 조회
	getDefaultDirector();

	// OS구분 코드 (코드값 : '2')
	setCommonCode('<c:url value="/codes/child/"/>'+'2', 'os');
	
	// OS버전 코드  (OS구분과 연관된 하위코드로 선택된 OS구분 코드의 값)
	setCommonCode('<c:url value="/codes/child/"/>' + $("#os option:selected").val(), 'osVersion');
	
	// IaaS 코드 (코드값 : '1')
	setCommonCode('<c:url value="/codes/child/"/>' + '1', 'iaas');
	
	// 스템셀 목록 조회
	doSearch();
}

function changeOS() {
	// OS버전 코드  (OS구분과 연관된 하위코드로 선택된 OS구분 코드의 값)
	setCommonCode('<c:url value="/codes/child/"/>' + $("#os option:selected").val(), 'osVersion');
}

// 스템셀 다운로드
function doDownload() {
	var selected = w2ui['config_opStemcellsGrid'].getSelection();
	if (selected == null || selected == '') {
		alert("다운로드받을 스템셀을 선택하세요.");
	}
	
	// 다운로드 요청
	var record = w2ui['config_opStemcellsGrid'].get(selected);
	alert(record.stemcellFileName);
	
/* 	$.ajax({
	type: "POST",
	url: "/downloadPublicStemcell",
	contentType: "application/json",
	//dataType: "json",
	async : true,
	data : JSON.stringify({
			userId 			: $("[name='userId']").val(),
			userPassword	: $("[name='userPassword']").val(),
			directorUrl		: $("[name='directorUrl']").val(),
			directorPort	: parseInt($("[name='directorPort']").val())
	}),
	success: function(data, status) {
		alert(status);
		w2popup.close();		
	},
	error:function(e) { 
		alert("오류가 발생하였습니다.");
		w2popup.close();
	}  */
}

// 스템셀 삭제
function doDelete() {
	var selected = w2ui['config_opStemcellsGrid'].getSelection();
	if (selected == null || selected == '') {
		alert("삭제할 스템셀을 선택하세요.");
	}
}


function doSearch() {
	
	var requestParam = "?os=" + $("#os option:selected").text();
	requestParam += "&osVersion=" + $("#osVersion option:selected").text();
	requestParam += "&iaas=" + $("#iaas option:selected").text();

	w2ui['config_opStemcellsGrid'].load("<c:url value='/publicStemcells'/>" + requestParam);
}

//다른페이지 이동시 호출
function clearMainPage() {
	$().w2destroy('config_opStemcellsGrid');
}

//화면 리사이즈시 호출
$( window ).resize(function() {
	setLayoutContainerHeight();
});

</script>

<div id="main">
	<div class="page_site">설치관리자 환경설정 > <strong>스템셀 관리</strong></div>
	
	<!-- OpenPaaS 스템셀 목록-->
	<div class="title">스템셀 목록</div>
	
<!-- 	<form id="searchPublicStemcell" method=post> -->
 	<div class="search_box" style align="center">
		<span class="search_li">OS</span>&nbsp;&nbsp;&nbsp;
		<select name="select" id="os" class="select" style="width:120px" onChange="changeOS();">
		</select>
		<span class="search_li">OS버전</span>&nbsp;&nbsp;&nbsp;
		<select name="select" id="osVersion" class="select" style="width:120px">
		</select>
		<span class="search_li">IaaS</span>&nbsp;&nbsp;&nbsp;
		<select name="select" id="iaas" class="select" style="width:120px">
		</select>
		&nbsp;&nbsp;&nbsp;
		<span class="btn btn-info" style="width:100px" id="doSearch">조회</span>
		<span class="btn btn-primary" style="width:100px" id="doDownload">다운로드</span>
		<span class="btn btn-danger" style="width:100px" id="doDelete">삭제</span>
	</div>
<!-- 	</form>
 -->	
	<div id="config_opStemcellsGrid" style="width:100%; height:500px"/>	
	
</div>