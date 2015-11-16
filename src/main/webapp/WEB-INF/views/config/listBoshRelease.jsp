<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<script type="text/javascript">

$(function() {
 	$('#config_opBoshReleaseGrid').w2grid({
		name: 'config_opBoshReleaseGrid',
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
			,{field: 'stemcellFileName', caption: '파일명', size: '40%', style: 'text-align:left'}
			,{field: 'isExisted', caption: '다운로드 여부', size: '10%',
				render: function(record) {
					if ( record.isExisted == 'Y')
						return '<div class="btn btn-success btn-xs" style="width:70px;">' + '완료 ' + '</div>';
				}
			}
		],
		onClick: function(event) {
			var grid = this;
			event.onComplete = function() {
/* 				var sel = grid.getSelection();
				if ( sel == null || sel == "") {
					$('#doDownload').attr('disabled', true);
					$('#doDelete').attr('disabled', true);
					return;
				}
				
				var record = grid.get(sel);
				if ( record.isExisted == 'Y' ) {
					// 다운로드 버튼 Disable
					$('#doDownload').attr('disabled', true);
					// 삭제 버튼 Enable
					$('#doDelete').attr('disabled', false);
				}
				else {
					// 다운로드 버튼 Enable
					$('#doDownload').attr('disabled', false);
					// 삭제 버튼 Disable
					$('#doDelete').attr('disabled', true);
				} */
			}
		}
		
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

	//	doSearch();
	
	// 다운로드 & 삭제버튼 Disable
//	$('#doDownload').attr('disabled', true);
//	$('#doDelete').attr('disabled', true);
}

//스템셀 목록 조회
function doSearch() {
/* 	var requestParam = "?os=" + $("#os option:selected").text();
	requestParam += "&osVersion=" + $("#osVersion option:selected").text();
	requestParam += "&iaas=" + $("#iaas option:selected").text();

	w2ui['config_opBoshReleaseGrid'].load("<c:url value='/publicStemcells'/>"
			+ requestParam); */
}

// 스템셀 다운로드
function doDownload() {
/* 	var selected = w2ui['config_opBoshReleaseGrid'].getSelection();

	var record = w2ui['config_opBoshReleaseGrid'].get(selected);

	var requestParameter = {
			key : record.key,
			fileName : record.stemcellFileName,
			fileSize : record.size
		};

	$.ajax({
		method : 'post',
		type : "json",
		url : "/downloadPublicStemcell",
		contentType : "application/json",
		data : JSON.stringify(requestParameter),
		success : function(data, status) {
			alert(status);
		},
		error : function(e) {
			alert("오류가 발생하였습니다.");
		}
	}); */
}

// 스템셀 삭제
function doDelete() {
/* 	var selected = w2ui['config_opBoshReleaseGrid'].getSelection();
	var record = w2ui['config_opBoshReleaseGrid'].get(selected);
	
	var requestParameter = { stemcellFileName: record.stemcellFileName };
	
	w2confirm( { msg : '선택된 스템셀 ' + record.stemcellFileName + '을 삭제하시겠습니까?'
		, title : '스템셀 삭제'
		, yes_text:'확인'
		, no_text:'취소'
		})
		.yes(function() {
			$.ajax({
				method : 'delete',
				type : "json",
				url : "/deletePublicStemcell",
				contentType : "application/json",
				data : JSON.stringify(requestParameter),
				success : function(data, status) {
					record.isExisted = 'N';
					w2ui['config_opBoshReleaseGrid'].reload();
					$('#doDelete').attr('disabled', true);
					w2ui['config_opBoshReleaseGrid'].selectNone();
					w2alert("삭제 처리가 완료되었습니다.", "스템셀  삭제");
				},
				error : function(e) {
					w2alert("오류가 발생하였습니다.");
				}
			});
		})
		.no(function() {
			// do nothing
		}); */
}

//다른페이지 이동시 호출
function clearMainPage() {
	$().w2destroy('config_opBoshReleaseGrid');
}

//화면 리사이즈시 호출
$(window).resize(function() {
	setLayoutContainerHeight();
});
</script>

<div id="main">
	<div class="page_site">설치관리자 환경설정 > <strong>BOSH 릴리즈 관리</strong></div>
	
	<!-- OpenPaaS 스템셀 목록-->
	<div class="title">릴리즈 목록</div>
	
 	<div class="search_box" align="center">
		<span class="search_li">릴리즈 버전</span>&nbsp;&nbsp;&nbsp;
		<!-- OS구분 -->
		<select name="select" id="os" class="select" style="width:120px">
		</select>
		&nbsp;&nbsp;&nbsp;
		
		<button type="button" class="btn btn-primary" style="width:100px" id="doDownload">다운로드</button>
		<button type="button" class="btn btn-danger" style="width:100px" id="doDelete">삭제</button>

	</div>
	
	<!-- 그리드 영역 -->
	<div id="config_opBoshReleaseGrid" style="width:100%; height:500px"></div>	
	
</div>