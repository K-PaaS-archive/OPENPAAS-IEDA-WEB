package org.openpaas.ieda.web.config.setting;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.URI;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.tomcat.util.codec.binary.Base64;
import org.modelmapper.ModelMapper;
import org.openpaas.ieda.api.DirectorClient;
import org.openpaas.ieda.api.DirectorClientBuilder;
import org.openpaas.ieda.api.DirectorEndPoint;
import org.openpaas.ieda.api.Info;
import org.openpaas.ieda.common.IEDACommonException;
import org.openpaas.ieda.common.IEDAConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.util.UriComponentsBuilder;
import org.yaml.snakeyaml.Yaml;

import lombok.extern.slf4j.Slf4j;

/**
 * @author "Cheolho, Moon <chmoon93@gmail.com / Cloud4U, Inc>"
 *
 */

@Service
@Transactional
@Slf4j
public class IEDADirectorConfigService {
	
	private DirectorEndPoint directorEndPoint = DirectorEndPoint.getInstance();

	@Autowired
	private IEDADirectorConfigRepository directorConfigRepository;

	@Autowired
	private ModelMapper modelMapper;
	
	@Autowired
	private IEDAConfiguration iedaConfiguration;
	
	public IEDADirectorConfig getDefaultDirector() {
		
		log.info("getDeploymentDir : " + iedaConfiguration.getDeploymentDir());
		log.info("getReleaseDir    : " + iedaConfiguration.getReleaseDir());
		log.info("getStemcellDir   : " + iedaConfiguration.getStemcellDir());
		
		IEDADirectorConfig directorConfig = directorConfigRepository.findOneByDefaultYn("Y");

		if ( directorConfig == null ) {
			throw new IEDACommonException("notfound.director.exception",
					"기본 설치관리자 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}

		return directorConfig;
	}
	
	public List<IEDADirectorConfig> listDirector() {
		
		List<IEDADirectorConfig> directorConfigList = directorConfigRepository.findAll();
		if ( directorConfigList.size() == 0 ) {
			throw new IEDACommonException("nocontent.director.exception",
					"디렉터 정보가 존재하지 않습니다.", HttpStatus.NO_CONTENT);
		}
		
		return directorConfigList;
	}
	
	//  map to api --> /info
	public Info getDirectorInfo(String directorUrl, int port, String userId, String password) {
		Info info = null;
		
		try {
			DirectorClient client = new DirectorClientBuilder()
					.withHost(directorUrl, port)
					.withCredentials(userId, password).build();
			URI infoUri = UriComponentsBuilder.fromUri(client.getRoot())
					.pathSegment("info").build().toUri();
			
      		ResponseEntity<Info> response = client.getRestTemplate().getForEntity(infoUri, Info.class);
			info = response.getBody();
			
		} catch (ResourceAccessException e) {
			e.printStackTrace();
			throw new IEDACommonException("notfound.director.exception", "["
					+ directorUrl + "] 디렉터를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
		} catch (Exception e) {
			e.printStackTrace();
			throw new IEDACommonException("notfound.director.exception",
					"요청정보가 올바르지 않습니다.", HttpStatus.BAD_REQUEST);
		}
	
		return info;
	}

	public IEDADirectorConfig createDirector(IEDADirectorConfigDto.Create createDto) {

		// 추가할 디렉터가 이미 존재하는지 여부 확인
		List<IEDADirectorConfig> directorConfigList = directorConfigRepository
				.findByDirectorUrl(createDto.getDirectorUrl());
		
		if ( directorConfigList.size() > 0 ) {
			throw new IEDACommonException("duplicated.director.exception",
					"이미 등록되어 있는 디렉터 URL입니다.", HttpStatus.BAD_REQUEST);
		}
		
		Info info = getDirectorInfo(createDto.getDirectorUrl()
								, createDto.getDirectorPort()
								, createDto.getUserId()
								, createDto.getUserPassword());
		
		log.info(info.toString());
		
		if ( info == null || info.getUser() == null || info.getUser().equals("") ) {
			throw new IEDACommonException("unauthenticated.director.exception",
					"해당 디렉터에 로그인 실패하였습니다.", HttpStatus.BAD_REQUEST);
		}
		
		Date now = new Date();

		IEDADirectorConfig director = new IEDADirectorConfig();

		director.setUserId(createDto.getUserId());
		director.setUserPassword(createDto.getUserPassword());
		director.setDirectorUrl(createDto.getDirectorUrl());
		director.setDirectorPort(createDto.getDirectorPort());
		director.setDirectorName(info.getName());
		director.setDirectorUuid(info.getUuid());
		director.setDirectorCpi(info.getCpi());
		director.setDirectorVersion(info.getVersion());
		
		IEDADirectorConfig directorConfig = directorConfigRepository.findOneByDefaultYn("Y");
		
		director.setDefaultYn((directorConfig == null ) ? "Y":"N");
		director.setUpdatedDate(now);
		director.setCreatedDate(now);
		
		// Target 설정
		if( director.getDefaultYn().equals("Y") ) {
			setTarget(director);
		}	

		return directorConfigRepository.save(director);
	}
	
	public IEDADirectorConfig getDirectorConfig(int seq) {
		IEDADirectorConfig directorConfig = directorConfigRepository
				.findByIedaDirectorConfigSeq(seq);

		if (directorConfig == null) {
			throw new IEDACommonException("illigalArgument.director.exception",
					"해당하는 디렉터가 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}
		
		return directorConfig;
	}

	public IEDADirectorConfig updateDirectorConfig(int seq,
			IEDADirectorConfigDto.Update updateDto) {

		IEDADirectorConfig directorConfig = directorConfigRepository
				.findByIedaDirectorConfigSeq(seq);

		if (directorConfig == null) {
			throw new IEDACommonException("illigalArgument.director.exception",
					"해당하는 디렉터가 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}

		Info info = null;

		try {
			DirectorClient client = new DirectorClientBuilder()
					.withHost(directorConfig.getDirectorUrl(),
							directorConfig.getDirectorPort())
					.withCredentials(updateDto.getUserId(),
							updateDto.getUserPassword()).build();

			URI infoUri = UriComponentsBuilder.fromUri(client.getRoot())
					.pathSegment("info").build().toUri();
			ResponseEntity<Info> response = client.getRestTemplate()
					.getForEntity(infoUri, Info.class);

			info = response.getBody();

			log.info(info.toString());

		} catch (ResourceAccessException e) {
			throw new IEDACommonException("notfound.director.exception", "["
					+ directorConfig.getDirectorUrl() + "] 디렉터를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
		} catch (Exception e) {
			throw new IEDACommonException("unknown.director.exception",
					"수정 중 알수없는 에러가 발생하였습니다.", HttpStatus.BAD_REQUEST);
		}

		directorConfig.setUserId(updateDto.getUserId());
		directorConfig.setUserPassword(updateDto.getUserPassword());

		return directorConfigRepository.save(directorConfig);
	}

	public void deleteDirectorConfig(int seq) {
		IEDADirectorConfig directorConfig = directorConfigRepository
				.findByIedaDirectorConfigSeq(seq);
		log.info("========== : " + seq);
		if (directorConfig == null) {
			throw new IEDACommonException("illigalArgument.director.exception",
					"해당하는 디렉터가 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}
		
		try {
			// bosh_config의 인증정보 초기화
			// set target
			String directorLink = "https://" + directorConfig.getDirectorUrl() + ":" + directorConfig.getDirectorPort();
			
			InputStream input = new FileInputStream(new File(getBoshConfigLocation()));
			Yaml yaml = new Yaml();
			Map<String, Object> object = (Map<String, Object>)yaml.load(input);

			// set auth
			Map<String, Object> authMap = (Map<String,Object>)object.get("auth");
			authMap.put(directorLink, null);
			
			// write file
			FileWriter fileWriter = new FileWriter(getBoshConfigLocation());
			StringWriter stringWriter = new StringWriter();
			yaml.dump(object, stringWriter);
			log.info(stringWriter.toString());
			fileWriter.write(stringWriter.toString());
			fileWriter.close();
			
			// 모델 데이터 삭제
			directorConfigRepository.delete(seq);
			
		} catch (Exception e) {
			throw new IEDACommonException("illigalArgument.director.exception",
					"설치관리자 삭제 중 오류가 발생하였습니다.", HttpStatus.NOT_FOUND);
		}
	}

	public void setDefaultDirector(int seq) {
		IEDADirectorConfig directorConfig = directorConfigRepository
				.findByIedaDirectorConfigSeq(seq);

		if (directorConfig == null) {
			throw new IEDACommonException("illigalArgument.director.exception",
					"해당하는 설치관리자 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}
		
		//Database
		IEDADirectorConfig oldDefaultDiretor = directorConfigRepository.findOneByDefaultYn("Y");
		if (oldDefaultDiretor != null) {
			oldDefaultDiretor.setDefaultYn("N");
			directorConfigRepository.save(oldDefaultDiretor);
		}
		directorConfig.setDefaultYn("Y");
		directorConfig= directorConfigRepository.save(directorConfig);
		
		// target 설정
		setTarget(directorConfig);
		
		//보쉬 타겟설정
		//setTarget(directorConfig.getDirectorUrl(), directorConfig.getDirectorPort());
	}

	/**
	 * Bosh 타겟 설정
	 * @param url
	 * @param port
	 */
	public void setTarget(IEDADirectorConfig directorConfig) {
		
		// set target
		String directorLink = "https://" + directorConfig.getDirectorUrl() + ":" + directorConfig.getDirectorPort();

		// Config File이 존재하느냐?
		if ( isExistBoshConfigFile() ) {
			// 읽어서 수정
			try {
				InputStream input = new FileInputStream(new File(getBoshConfigLocation()));
				Yaml yaml = new Yaml();
				Map<String, Object> object = (Map<String, Object>)yaml.load(input);
				
				// set target
				object.put("target", directorLink);
				object.put("target_name", directorConfig.getDirectorName());
				object.put("target_version", directorConfig.getDirectorVersion());
				object.put("target_uuid", directorConfig.getDirectorUuid());
				
				// set ca_cert
				Map<String, String> certMap = (Map<String,String>)object.get("ca_cert");
				certMap.put(directorLink, null);
				
				// set aliases
				Map<String, Object> aliasMap = (Map<String,Object>)object.get("aliases");
				Map<String, Object> targetMap = (Map<String,Object>)aliasMap.get("target");
				targetMap.put(directorConfig.getDirectorUuid(), directorLink);
				
				// set auth
				Map<String, String> accountMap = new HashMap<String, String>();
				accountMap.put("username", directorConfig.getUserId());
				accountMap.put("password", directorConfig.getUserPassword());
				
				Map<String, Object> authMap = (Map<String,Object>)object.get("auth");
				authMap.put(directorLink, accountMap);
				
				// write file
				FileWriter fileWriter = new FileWriter(getBoshConfigLocation());
				StringWriter stringWriter = new StringWriter();
				yaml.dump(object, stringWriter);
				log.info(stringWriter.toString());
				fileWriter.write(stringWriter.toString());
				fileWriter.close();
				
			} catch (IOException e) {
				throw new IEDACommonException("taretDirector.director.exception",
						"설치관리자 타겟 설정 중 오류 발생하였습니다.", HttpStatus.NOT_FOUND);
			}
			
		}
		else {
			try {
				// 생성
				Map<String, Object> newConfig = new HashMap<String, Object>();
				
				// set target
				newConfig.put("target", directorLink);
				newConfig.put("target_name", directorConfig.getDirectorName());
				newConfig.put("target_version", directorConfig.getDirectorVersion());
				newConfig.put("target_uuid", directorConfig.getDirectorUuid());
				
				// set ca_cert
				Map<String, Object> certMap = new HashMap<String, Object>();
				certMap.put(directorLink, null);
				newConfig.put("ca_cert", certMap);
				
				// set aliases
				Map<String, Object> aliasesMap = new HashMap<String, Object>();
				aliasesMap.put(directorConfig.getDirectorUuid(), directorLink);
	
				Map<String, Object> targetMap = new HashMap<String, Object>();
				targetMap.put("target", aliasesMap);
				
				newConfig.put("aliases", targetMap);
				
				// set auth
				Map<String, String> accountInfo = new HashMap<String, String>();
				accountInfo.put("username", directorConfig.getUserId());
				accountInfo.put("password", directorConfig.getUserPassword());
				
				Map<String, Object> authMap = new HashMap<String, Object>();
				authMap.put(directorLink, accountInfo);
				newConfig.put("auth", authMap);
				
				Yaml yaml = new Yaml();
				
				// write file
				FileWriter fileWriter = new FileWriter(getBoshConfigLocation());
				StringWriter stringWriter = new StringWriter();
				yaml.dump(newConfig, stringWriter);
				log.info(stringWriter.toString());
				fileWriter.write(stringWriter.toString());
				fileWriter.close();
			} catch (IOException e) {
				throw new IEDACommonException("taretDirector.director.exception",
						"설치관리자 설정 파일 생성 중 오류 발생하였습니다.", HttpStatus.NOT_FOUND);
			}
			
		}
	}
	
	public String getBoshConfigLocation() {
		String homeDir = System.getProperty("user.home");
		String boshConfigFile = homeDir + "\\.bosh_config";
		System.out.println("BOSH Config File Location : " + homeDir);
		return boshConfigFile;
	}
	
	public boolean isExistBoshConfigFile() {
		File f = new File(getBoshConfigLocation());
		return f.exists();
	}
}
