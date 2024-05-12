async function main() {
    const Token = await ethers.getContractFactory("HelloWorld");
    console.log("Deploying Token contract...");
    // const initSupply = ethers.utils.parseUnits("200000000000000", 18); // Convert to the appropriate number of tokens based on the token's decimals (assuming 18 decimals)
    const token = await Token.deploy();
    // console.log("token:",token)
    console.log("Token contract deployed to:", token.address);

    const Vote = await ethers.getContractFactory("Voting");
    console.log("Deploying Voting contract...");
    const vote = await Vote.deploy();
    console.log("Vote contract deployed to:", vote.address);

    const Rov = await ethers.getContractFactory("Rov");
    console.log("Deploying Voting contract...");
    const rov = await Vote.deploy();
    console.log("Rov contract deployed to:", rov.address);
}

main().then(()=>process.exit(0)).catch(error=>{
    console.error(error);
    process.exit(1);
})