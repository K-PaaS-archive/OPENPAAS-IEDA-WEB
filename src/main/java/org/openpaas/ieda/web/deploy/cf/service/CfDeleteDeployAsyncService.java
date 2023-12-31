package org.openpaas.ieda.web.deploy.cf.service;

import java.security.Principal;
import java.util.Arrays;

import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.openpaas.ieda.api.director.utility.DirectorRestHelper;
import org.openpaas.ieda.common.CommonException;
import org.openpaas.ieda.web.common.dto.SessionInfoDTO;
import org.openpaas.ieda.web.config.setting.dao.DirectorConfigVO;
import org.openpaas.ieda.web.config.setting.service.DirectorConfigService;
import org.openpaas.ieda.web.deploy.cf.dao.CfDAO;
import org.openpaas.ieda.web.deploy.cf.dao.CfVO;
import org.openpaas.ieda.web.deploy.cf.dto.CfParamDTO;
import org.openpaas.ieda.web.deploy.common.dao.network.NetworkDAO;
import org.openpaas.ieda.web.deploy.common.dao.resource.ResourceDAO;
import org.openpaas.ieda.web.management.code.dao.CommonCodeDAO;
import org.openpaas.ieda.web.management.code.dao.CommonCodeVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class CfDeleteDeployAsyncService {
	
	@Autowired private SimpMessagingTemplate messagingTemplate;
	@Autowired private DirectorConfigService directorConfigService;
	@Autowired private CfDAO cfDao;
	@Autowired private NetworkDAO networkDao;
	@Autowired private ResourceDAO resourceDao;
	@Autowired private CommonCodeDAO commonCodeDao;
	
	final private static String PARENT_CODE="1000"; //배포 코드
	final private static String SUB_GROUP_CODE="1100"; //배포 유형 코드
	final private static String STATUS_SUB_GROUP_CODE="1200"; //배포 상태 코드
	final private static String CODE_NAME="DEPLOY_TYPE_CF"; //배포 할 플랫폼명
	
	/***************************************************
	 * @project          : Paas 플랫폼 설치 자동화
	 * @description   : CF 플랫폼 삭제 요청
	 * @title               : deleteDeploy
	 * @return            : void
	***************************************************/
	public void deleteDeploy(CfParamDTO.Delete dto, String platform, Principal principal) {
		String messageEndpoint = "/deploy/"+platform+"/delete/logs"; 
		CfVO vo = null;
		String deploymentName = null;
		CommonCodeVO commonCode = null;
		SessionInfoDTO sessionInfo = new SessionInfoDTO(principal);
		
		
		vo = cfDao.selectCfInfoById(Integer.parseInt(dto.getId()));
		if ( vo != null ) deploymentName = vo.getDeploymentName();
			
		if ( StringUtils.isEmpty(deploymentName) ) {
			throw new CommonException("cfInfoNotfound.cfdelete.exception",
					"배포정보가 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}
		DirectorConfigVO defaultDirector = directorConfigService.getDefaultDirector();

		if ( vo != null ) {
			commonCode = commonCodeDao.selectCommonCodeByCodeName(PARENT_CODE, STATUS_SUB_GROUP_CODE, "DEPLOY_STATUS_DELETING");
			if( commonCode != null ){
				vo.setDeployStatus(commonCode.getCodeValue());
				vo.setUpdateUserId(sessionInfo.getUserId());
				saveDeployStatus(vo);
			}
		}
		
		try {
			HttpClient httpClient = DirectorRestHelper.getHttpClient(defaultDirector.getDirectorPort());
			
			DeleteMethod deleteMethod = new DeleteMethod(DirectorRestHelper.getDeleteDeploymentURI(defaultDirector.getDirectorUrl(), defaultDirector.getDirectorPort(), deploymentName));
			deleteMethod = (DeleteMethod)DirectorRestHelper.setAuthorization(defaultDirector.getUserId(), defaultDirector.getUserPassword(), (HttpMethodBase)deleteMethod);
		
			int statusCode = httpClient.executeMethod(deleteMethod);
			if ( statusCode == HttpStatus.MOVED_PERMANENTLY.value()
			  || statusCode == HttpStatus.MOVED_TEMPORARILY.value()	) {
				
				Header location = deleteMethod.getResponseHeader("Location");
				String taskId = DirectorRestHelper.getTaskId(location.getValue());
				
				DirectorRestHelper.trackToTask(defaultDirector, messagingTemplate, messageEndpoint, httpClient, taskId, "event", principal.getName());
			} else {
				DirectorRestHelper.sendTaskOutput(principal.getName(), messagingTemplate, messageEndpoint, "done", Arrays.asList("CF 삭제가 완료되었습니다."));
			}
			deleteCfInfo(vo);
		} catch(RuntimeException e){
			DirectorRestHelper.sendTaskOutput(principal.getName(), messagingTemplate, messageEndpoint, "error", Arrays.asList("배포삭제 중 Exception이 발생하였습니다."));
		} catch ( Exception e) {
			DirectorRestHelper.sendTaskOutput(principal.getName(), messagingTemplate, messageEndpoint, "error", Arrays.asList("배포삭제 중 Exception이 발생하였습니다."));
		}
	}
	
	/***************************************************
	 * @project          : Paas 플랫폼 설치 자동화
	 * @description   : CF 정보 삭제
	 * @title               : deleteCfInfo
	 * @return            : void
	***************************************************/
	@Transactional
	public void deleteCfInfo( CfVO vo ){
		if ( vo != null ) {
			cfDao.deleteCfInfoRecord(vo.getId());
			CommonCodeVO codeVo = commonCodeDao.selectCommonCodeByCodeName(PARENT_CODE, SUB_GROUP_CODE, CODE_NAME);
			networkDao.deleteNetworkInfoRecord( vo.getId(), codeVo.getCodeName() );
			resourceDao.deleteResourceInfo( vo.getId(), codeVo.getCodeName() );	
		}
	}
	
	/***************************************************
	 * @project          : Paas 플랫폼 설치 자동화
	 * @description   : CF 배포 상태 저장
	 * @title               : saveDeployStatus
	 * @return            : CfVO
	***************************************************/
	public CfVO saveDeployStatus(CfVO cfVo) {
		if ( cfVo == null ) return null;
		cfDao.updateCfInfo(cfVo);
		return cfVo;
	}

	/***************************************************
	 * @project          : Paas 플랫폼 설치 자동화
	 * @description   : 비동기식으로 deleteDeploy 콜
	 * @title               : deleteDeployAsync
	 * @return            : void
	***************************************************/
	@Async
	public void deleteDeployAsync(CfParamDTO.Delete dto, String platform, Principal principal) {
		deleteDeploy(dto, platform, principal);
	}	
}
