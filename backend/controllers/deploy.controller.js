import { execSync, exec } from 'child_process';
import Deployment from '../models/deployment.model.js';

export const deployProject = async (req, res) => {
    try {
        const { repo, branch, username, deploymentId, envVars } = req.body;

        if (!repo || !branch || !username || !deploymentId) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const kafkaBroker = process.env.KAFKA_BROKER || 'kafka-1:19092';
        const buildServerImage = process.env.BUILD_SERVER_IMAGE || 'vortex-build-server:latest';
        const containerName = `${deploymentId}`;

        // Ensure build-server image exists on the host
        try {
            execSync(`docker image inspect ${buildServerImage}`);
        } catch (inspectError) {
            console.log(`[Vortex Deploy] Image ${buildServerImage} not found. Building it automatically from /home/ubuntu/vortex/build-server...`);
            try {
                execSync(`docker build -t ${buildServerImage} /home/ubuntu/vortex/build-server`);
                console.log(`[Vortex Deploy] Image ${buildServerImage} built successfully.`);
            } catch (buildError) {
                console.error(`[Vortex Deploy] Failed to build image ${buildServerImage}:`, buildError);
                return res.status(500).json({ error: 'Failed to build required builder image on host' });
            }
        }
        try {
            execSync(`docker inspect ${containerName}`);
            execSync(`docker rm -f ${containerName}`);
        } catch {
        }

        const dockerRunCommand = [
            `docker run -d`,
            `--name ${containerName}`,
            `--network deployment`,
            `-e REPO=${repo}`,
            `-e BRANCH=${branch}`,
            `-e USERNAME=${username}`,
            `-e DEPLOYMENT_ID=${deploymentId}`,
            `-e KAFKA_BROKER=${kafkaBroker}`,
            `-e KAFKA_TOPIC=${process.env.KAFKA_TOPIC || 'build-logs'}`,
            `-e REGION=${process.env.AWS_REGION || process.env.REGION || 'eu-north-1'}`,
            `-e ACCESS_KEY_ID=${process.env.AWS_ACCESS_KEY_ID || process.env.ACCESS_KEY_ID || ''}`,
            `-e SECRET_ACCESS_KEY=${process.env.SECRET_ACCESS_KEY || process.env.AWS_SECRET_ACCESS_KEY || ''}`,
            `-e S3_BUCKET=${process.env.S3_BUCKET || ''}`,
            `-e ENV='${JSON.stringify(envVars)}'`,
            buildServerImage
        ].join(' ');

        const containerId = execSync(dockerRunCommand).toString().trim();
        res.status(200).json({ message: 'Deployment started', deploymentId: deploymentId });

        exec(`docker wait ${containerName}`, (err, stdout) => {
            const exitCode = stdout?.trim();
        });

    } catch (error) {
        console.error('Error starting deployment:', error);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
};

export const createDeployment = async (req, res) => {
    try {
        let { deploymentId, repoName, branch, username, logs, url } = req.body;

        if (url) {
            url = url.replace(/deployment-build-artifacts-bucket\.s3\.us-east-1/g, 'eshwar-vortex-storage.s3.eu-north-1');
        }

        if (!deploymentId || !repoName || !branch || !username || !url) {
            return res.status(400).json({ message: 'Missing required fields' });
        }
        const existingDeployment = await Deployment.findOne({ deploymentId });

        if (existingDeployment) {
            existingDeployment.repoName = repoName;
            existingDeployment.branch = branch;
            existingDeployment.username = username;
            existingDeployment.logs = logs || [];
            existingDeployment.url = url;

            await existingDeployment.save();

            return res.status(200).json({
                message: 'Deployment updated successfully',
                deployment: existingDeployment,
            });
        } else {
            const newDeployment = new Deployment({
                deploymentId,
                repoName,
                branch,
                username,
                logs: logs || [],
                url,
            });

            await newDeployment.save();

            return res.status(201).json({
                message: 'Deployment created successfully',
                deployment: newDeployment,
            });
        }
    } catch (error) {
        console.error('Error creating deployment:', error);
        res.status(500).json({ message: 'Server error while creating deployment' });
    }
};



export const getDeploymentByRepoAndUser = async (req, res) => {
    try {
        const { repoName, username } = req.query;

        if (!repoName || !username) {
            return res.status(400).json({ message: 'repoName and username are required' });
        }

        const deploymentExists = await Deployment.exists({ repoName, username });

        res.status(200).json({ exists: !!deploymentExists });
    } catch (error) {
        console.error('Error checking deployment existence:', error);
        res.status(500).json({ message: 'Server error while checking deployment existence' });
    }
};

export const getDeploymentsByUser = async (req, res) => {
    try {
        const { user } = req.query;

        if (!user) {
            return res.status(400).json({ message: "User parameter is required" });
        }

        const deployments = await Deployment.find({ username: user });
        const sanitizedDeployments = deployments.map(dep => {
            const depObj = dep.toObject();
            if (depObj.url) {
                depObj.url = depObj.url.replace(/deployment-build-artifacts-bucket\.s3\.us-east-1/g, 'eshwar-vortex-storage.s3.eu-north-1');
            }
            return depObj;
        });
        res.status(200).json(sanitizedDeployments);
    } catch (err) {
        console.error("Error fetching deployments:", err);
        res.status(500).json({ message: "Server error" });
    }
};

