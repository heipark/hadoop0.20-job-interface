<%@ page
  contentType="text/xml; charset=UTF-8"
  import="javax.servlet.*"
  import="javax.servlet.http.*"
  import="java.io.*"
  import="java.net.URL"
  import="org.apache.hadoop.util.*"
  import="javax.servlet.jsp.JspWriter"
%><%!	
	private static final long serialVersionUID = 1L;

        public File getHistoryFile(final String jobId) {
                File dir = new File("/opt/hadoop/logs/history/done/");

                File[] files = dir.listFiles(new FilenameFilter() {
                        public boolean accept(File dir, String name) {
				if (name.indexOf(jobId) >= 0 && name.endsWith(".xml")) {
					return true;
				}
                                return false;
                        }
                });

                if (files != null && files.length > 0) {
                        return files[0];
                }
                return null;
        }

	public void printXML(JspWriter out, String jobId) throws IOException {
		FileInputStream jobFile = null;
		String[] outputKeys = { "db_id", "channel_id", "channel_name", "user_id", "user_name", "job_day", "pub_format_type", "mapred.output.dir" };
		String line = "";
		try {
			jobFile = new FileInputStream(getLogFilePath(jobId));
			BufferedReader reader = new BufferedReader(new InputStreamReader(jobFile));

			while ((line = reader.readLine()) != null) {
				for (String key : outputKeys) {
					if (!line.startsWith("<property>") || line.indexOf("<name>" + key + "</name>") >= 0) {
						out.println(line);
						break;
					}
				}
			}
		} catch (Exception e) {
			out.println("Failed to retreive job configuration for job '" + jobId + "!");
			out.println(e);
		} finally {
			if (jobFile != null) {
				try {
					jobFile.close();
				} catch (IOException e) {
				}
			}
		}
	}

	private File getLogFilePath(String jobId) {
		String logDir = System.getProperty("hadoop.log.dir");
		if (logDir == null || logDir.length() == 0) {
			logDir = "/opt/hadoop/logs/";
		}
		File logFile = new File(logDir + File.separator + jobId + "_conf.xml");
		return logFile.exists() ? logFile : getHistoryFile(jobId);
	}

%><%
  response.setContentType("text/xml");
  final String jobId = request.getParameter("jobid");
  if (jobId == null) {
    out.println("<h2>Missing 'jobid' for fetching job configuration!</h2>");
    return;
  }

  printXML(out, jobId);

%>

