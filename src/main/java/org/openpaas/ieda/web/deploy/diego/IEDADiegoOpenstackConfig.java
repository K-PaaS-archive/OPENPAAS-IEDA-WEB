package org.openpaas.ieda.web.deploy.diego;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import lombok.Data;

@Entity(name="IEDA_DIEGO_OPENSTACK")
@Data
public class IEDADiegoOpenstackConfig {
	@Id @GeneratedValue
	private Integer id;
	
	@Temporal(TemporalType.DATE)
	private Date createdDate;
	
	@Temporal(TemporalType.DATE)
	private Date updatedDate;
	
	//1.1 기본정보	
	@Column(length = 100)
	private String deploymentName;
	@Column(length = 100)
	private String directorUuid;
	@Column(length = 100)
	private String diegoReleaseName;
	@Column(length = 100)
	private String diegoReleaseVersion;
	@Column(length = 100)
	private String cfReleaseName;
	@Column(length = 100)
	private String cfReleaseVersion;
	@Column(length = 100)
	private String gardenLinuxReleaseName;
	@Column(length = 100)
	private String gardenLinuxReleaseVersion;
	@Column(length = 100)
	private String etcdReleaseName;
	@Column(length = 100)
	private String etcdReleaseVersion;
	//1.2 CF 정보
	@Column(length = 100)
	private String domain;
	@Column(length = 100)
	private String deployment;
	@Column(length = 100)
	private String secret;
	@Column(length = 100)
	private String etcdMachines;
	@Column(length = 100)
	private String natsMachines;
	@Column(length = 100)
	private String consulServersLan;
	@Column(length = 2000)
	private String consulAgentCert;
	@Column(length = 2000)
	private String consulAgentKey;
	@Column(length = 2000)
	private String consulCaCert;
	private String consulEncryptKeys;
	@Column(length = 2000)
	private String consulServerCert;
	@Column(length = 2000)
	private String consulServerKey;
	
	//2.1 Diego 정보	
	@Column(length = 2000)
	private String diegoCaCert;
	@Column(length = 2000)
	private String diegoClientCert;
	@Column(length = 2000)
	private String diegoClientKey;
	@Column(length = 2000)
	private String diegoEncryptionKeys;
	@Column(length = 2000)
	private String diegoServerCert;
	@Column(length = 2000)
	private String diegoServerKey;
	//2.2 ETCD 정보	
	@Column(length = 2000)
	private String etcdClientCert;
	@Column(length = 2000)
	private String etcdClientKey;
	@Column(length = 2000)
	private String etcdPeerCaCert;
	@Column(length = 2000)
	private String etcdPeerCert;
	@Column(length = 2000)
	private String etcdPeerKey;
	@Column(length = 2000)
	private String etcdServerCert;
	@Column(length = 2000)
	private String etcdServerKey;
	
	//3.1 네트워크 정보
	@Column(length = 100)
	private String subnetStaticFrom;
	@Column(length = 100)
	private String subnetStaticTo;
	@Column(length = 100)
	private String subnetReservedFrom;
	@Column(length = 100)
	private String subnetReservedTo;
	@Column(length = 100)
	private String subnetRange;
	@Column(length = 100)
	private String subnetGateway;
	@Column(length = 100)
	private String subnetDns;
	@Column(length = 100)
	private String cloudNetId;
	@Column(length = 100)
	private String cloudSecurityGroups;	
	//3.2 프록시 정보
	@Column(length = 2000)
	private String diegoHostKey;
	
	//4 리소스 정보	
	@Column(length = 200)
	private String boshPassword;
	@Column(length = 100)
	private String stemcellName;
	@Column(length = 100)
	private String stemcellVersion;

	// Deploy 정보
	@Column(length = 100)
	private String deploymentFile;
	@Column(length = 100)
	private String deployStatus;
	private Integer taskId;
}