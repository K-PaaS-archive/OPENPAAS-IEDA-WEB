package org.openpaas.ieda.web.deploy.diego;

import java.util.Date;

import org.openpaas.ieda.common.IEDACommonException;
import org.openpaas.ieda.web.deploy.diego.DiegoParam.Cf;
import org.openpaas.ieda.web.deploy.diego.DiegoParam.Etcd;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class IEDADiegoAwsService {

	@Autowired
	private IEDADiegoAwsRepository awsRepository;
	@Autowired
	private IEDADiegoService diegoService;

	public IEDADiegoAwsConfig getAwsInfo(int id) {
		IEDADiegoAwsConfig config = null;
		try{
			config = awsRepository.findOne(id);
		}
		catch (Exception e){
			e.printStackTrace();
			throw new IEDACommonException("illigalArgument.diego.aws.exception",
					"해당하는 AWS DIEGO가 존재하지 않습니다.", HttpStatus.NOT_FOUND);
		}
		return config;
	}

	public IEDADiegoAwsConfig saveDefaultInfo(DiegoParam.Default dto) {
		IEDADiegoAwsConfig config;
		Date now = new Date();
		if( StringUtils.isEmpty(dto.getId()) ){
			config = new IEDADiegoAwsConfig();
			config.setCreatedDate(now);		
		}else{
			config = awsRepository.findOne(Integer.parseInt(dto.getId()));
		}
		// 1.1 기본정보
		config.setDeploymentName(dto.getDeploymentName());
		config.setDirectorUuid(dto.getDirectorUuid());
		config.setDiegoReleaseName(dto.getDiegoReleaseName());
		config.setDiegoReleaseVersion(dto.getDiegoReleaseVersion());
		config.setCfReleaseName(dto.getCfReleaseName());
		config.setCfReleaseVersion(dto.getCfReleaseVersion());
		config.setGardenLinuxReleaseName(dto.getGardenLinuxReleaseName());
		config.setGardenLinuxReleaseVersion(dto.getGardenLinuxReleaseVersion());
		config.setEtcdReleaseName(dto.getEtcdReleaseName());
		config.setEtcdReleaseVersion(dto.getEtcdReleaseVersion());

		config.setUpdatedDate(now);

		return awsRepository.save(config);
	}

	public IEDADiegoAwsConfig saveCfInfo(Cf dto) {
		IEDADiegoAwsConfig config = awsRepository.findOne(Integer.parseInt(dto.getId()));
		//1.2 CF 정보
		config.setDomain(dto.getDomain());
		config.setDeployment(dto.getDeployment());
		config.setSecret(dto.getSecret());
		config.setEtcdMachines(dto.getEtcdMachines());
		config.setNatsMachines(dto.getNatsMachines());
		config.setConsulServersLan(dto.getConsulServersLan());
		config.setConsulAgentCert(dto.getConsulAgentCert());
		config.setConsulAgentKey(dto.getConsulAgentKey());
		config.setConsulCaCert(dto.getConsulCaCert());
		config.setConsulEncryptKeys(dto.getConsulEncryptKeys());
		config.setConsulServerCert(dto.getConsulServerCert());
		config.setConsulServerKey(dto.getConsulServerKey());
		Date now = new Date();
		config.setUpdatedDate(now);
		return awsRepository.save(config);
	}

	public IEDADiegoAwsConfig saveDiegoInfo(DiegoParam.Diego dto) {
		IEDADiegoAwsConfig config = awsRepository.findOne(Integer.parseInt(dto.getId()));
		//2.1 Diego 정보	
		config.setDiegoCaCert(dto.getDiegoCaCert());
		config.setDiegoClientCert(dto.getDiegoClientCert());
		config.setDiegoClientKey(dto.getDiegoClientKey());
		config.setDiegoEncryptionKeys(dto.getDiegoEncryptionKeys());
		config.setDiegoServerCert(dto.getDiegoServerCert());
		config.setDiegoServerKey(dto.getDiegoServerKey());

		Date now = new Date();
		config.setUpdatedDate(now);
		return awsRepository.save(config);
	}

	public IEDADiegoAwsConfig saveEtcdInfo(DiegoParam.Etcd dto) {
		IEDADiegoAwsConfig config = awsRepository.findOne(Integer.parseInt(dto.getId()));
		//2.2 ETCD 정보
		config.setEtcdClientCert(dto.getEtcdClientCert());
		config.setEtcdClientKey(dto.getEtcdClientKey());
		config.setEtcdPeerCaCert(dto.getEtcdPeerCaCert());
		config.setEtcdPeerCert(dto.getEtcdPeerCert());
		config.setEtcdPeerKey(dto.getEtcdPeerKey());
		config.setEtcdServerCert(dto.getEtcdServerCert());
		config.setEtcdServerKey(dto.getEtcdServerKey());

		Date now = new Date();
		config.setUpdatedDate(now);
		return awsRepository.save(config);
	}

	public IEDADiegoAwsConfig saveNetworkInfo(DiegoParam.AwsNetwork dto){
		IEDADiegoAwsConfig config = awsRepository.findOne(Integer.parseInt(dto.getId()));

		config.setSubnetRange(dto.getSubnetRange());
		config.setSubnetGateway(dto.getSubnetGateway());
		config.setSubnetDns(dto.getSubnetDns());

		config.setSubnetReservedFrom(dto.getSubnetReservedFrom());;
		config.setSubnetReservedTo(dto.getSubnetReservedTo());;
		config.setSubnetStaticFrom(dto.getSubnetStaticFrom());
		config.setSubnetStaticTo(dto.getSubnetStaticTo());

		config.setSubnetId(dto.getSubnetId());
		config.setCloudSecurityGroups(dto.getCloudSecurityGroups());

		config.setDiegoHostKey(dto.getDiegoHostKey());
		config.setDiegoServers(dto.getDiegoServers());
		config.setDiegoUaaSecret(dto.getDiegoUaaSecret());

		Date now = new Date();
		config.setUpdatedDate(now);
		return awsRepository.save(config);
	}

	public IEDADiegoAwsConfig saveResourceInfo(DiegoParam.Resource dto){
		IEDADiegoAwsConfig config = awsRepository.findOne(Integer.parseInt(dto.getId()));
		config.setStemcellName(dto.getStemcellName());
		config.setStemcellVersion(dto.getStemcellVersion());
		config.setBoshPassword(dto.getBoshPassword());

		String deplymentFileName = diegoService.createSettingFile(Integer.parseInt(dto.getId()), "AWS");
		config.setDeploymentFile(deplymentFileName);
		Date now = new Date();
		config.setUpdatedDate(now);

		return awsRepository.save(config);
	}

}