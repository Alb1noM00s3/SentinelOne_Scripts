#SentinelOne_Scripts
A curated collection of advanced SentinelOne automation scripts designed to optimize endpoint security posture and streamline threat management across your deployment.

S1_Env_Check – The Heavy Hitter
This script performs a comprehensive environment audit by querying all endpoints in your deployment. It identifies assets with agent functionality issues that could compromise protection, flags unresolved threats, and exports findings to a structured .csv report. Additionally, it leverages VirusTotal integration to perform hash-based reputation checks. Results—including endpoints with agent anomalies and VirusTotal verdicts—are presented in a clean, actionable format for rapid remediation.

SentinelOne_Virustotal_ScanUnresolved
A leaner variant focused exclusively on threat intelligence. This script bypasses agent health checks and zeroes in on unresolved threats, executing VirusTotal hash lookups to deliver quick insights into potential risks.
